# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Tripitaka91 (`tripitaka91`) is a Flutter app for reading the Thai-translated Tipitaka and commentaries (พระไตรปิฎกและอรรถกถาแปล ชุด 91 เล่ม ฉบับ มมร.) — 91 volumes of scripture text plus a Pali-Thai dictionary. The UI is entirely in Thai. Supported runtime platforms are Android, iOS, macOS, Windows, and web; only Linux is explicitly unsupported at runtime (see `PlatformCheckerScreen` in `lib/main.dart`). The web build has no bundled SQLite database, so it always runs in online mode, hitting the remote API instead of the local DB that every other platform uses offline-first.

## Commands

```bash
flutter pub get                     # install dependencies
flutter run                         # run on a connected device/emulator
flutter run -d windows              # run the Windows desktop target
flutter run -d chrome               # run the web target (always online mode, no bundled DB)
flutter test                        # run all tests
flutter test test/widget_test.dart  # run a single test file
flutter analyze                     # static analysis (flutter_lints, see analysis_options.yaml)
flutter build apk / appbundle       # Android release build
flutter build ios                   # iOS release build
flutter build windows               # Windows release build
flutter build web                   # web release build
```

Note: `test/widget_test.dart` is still the default Flutter counter-app smoke test and does not exercise this app's actual screens — treat it as a placeholder, not a source of behavioral guarantees.

## Architecture

### Bootstrapping and the bundled database

The app ships its entire content database as a **zipped SQLite file bundled as an asset** (`assets/db/tripitaka91.zip`), not fetched at runtime. On first launch:

1. `main()` (`lib/main.dart`) wraps the app in `Phoenix` (enables full app restart, used elsewhere for state resets) and a `MultiProvider` (`ThemeProvider`, `UserProvider`, `OnlineSpeechProvider`).
2. `PlatformCheckerScreen` branches by platform: Android/iOS/macOS/Windows → `UnzipScreen` (unzips the bundled DB, below); web → straight to `MyHomePage(online: true)`, skipping the unzip step entirely since there's no bundled SQLite on web (every reading/search widget already branches on `online` to call the remote API instead of `DatabaseHelper`); others (Linux) → `UnsupportedPlatformScreen`.
3. `UnzipScreen` (`loadFromFuture()` in `main.dart`) copies the zip from `rootBundle` into the app's documents/support directory (path differs per platform — Android uses `.../databases`, Windows uses `getApplicationSupportDirectory()`), unzips it with `package:archive`, and stores the resulting `.db` path in `SharedPreferences` under the key `dbPath`. This only happens once; subsequent launches detect the existing `.db` file and skip re-extraction.
4. It also does an online check (`checkInternetConnection()` in `lib/utils/connectivity/check_internet_connection.dart`, which probes the backend directly rather than inferring from a cached login) to determine an `online` flag, which is threaded down into `MyHomePage`.

`DatabaseHelper` (`lib/utils/db_helper/db_helper.dart`, singleton) opens the SQLite DB at the `dbPath` stored in `SharedPreferences` and exposes query methods per feature (dictionary search, book/title search, last-read tracking, etc.) using raw `sqflite` queries — there is no ORM layer. Most search queries build dynamic `WHERE`/`LIKE` clauses to replicate legacy PHP search behavior (including special-casing certain Thai leading vowel characters).

### Web support

The web build skips the bundled-database path above entirely and always runs online (see `PlatformCheckerScreen`). A few platform-detection gotchas to know when touching shared code:

- `dart:io`'s `Platform` throws on web instead of returning `false` — any check that needs to special-case web (e.g. `lib/utils/constants/online_label.dart`'s `kOnlineModeLabel`) must test `kIsWeb` *first* and short-circuit before touching `Platform.*`.
- Browser-only APIs (file download, etc.) go through a conditional-import split rather than a direct `dart:html`/`dart:js_interop` import: a shared file (e.g. `lib/utils/img_service/web_download.dart`) exports a stub implementation that throws `UnsupportedError`, conditionally replaced by the real `package:web`-based implementation (`web_download_web.dart`) via `if (dart.library.js_interop)`. Follow this pattern for any new web-only capability instead of importing `dart:html` directly (it no longer compiles) or calling a plugin with no web implementation (e.g. `path_provider`, `permission_handler`) unconditionally.
- `permission_handler`'s storage permission request is skipped on web outright (`kIsWeb` check in `lib/widget/my_home_page.dart`) rather than requested-and-caught, since there's no such permission concept there.

### Local vs. remote data

- **Local (offline-first):** book text, titles, and dictionary content are read from the bundled SQLite DB via `DatabaseHelper`. This is what makes the app usable without a network connection.
- **Remote (online features):** user accounts, login, edit-log/speech-log submissions, and some search/random-title endpoints call a PHP backend at `https://www.tripitaka91.com/workspace/`. Every endpoint URL is a constant in `lib/utils/constants/api_constants.dart` (`tURL...`). Each remote endpoint has a matching `RemoteService*` class in `lib/utils/api_connect/remote_service.dart` that does a manual `http.post` + `jsonDecode`/`jsonEncode` round trip and parses the result via a `fromJson` in the corresponding `lib/utils/models/*.dart` file. There is no shared HTTP client wrapper — each `RemoteService*` class repeats the same request/decode pattern.
- Session/user state persists via `SharedPreferences` (`lib/utils/shared_preferences/shared_user.dart`, `shared_value.dart`); `AuthenticationService.checkLoginStatus()` just checks for a stored `usersList` key.

### Responsive layout

The app has three separate layout implementations selected by screen width, not one adaptive layout:

- `ResponsiveLayoutClass` (`lib/widget/screen/respond_screen.dart`) uses a `LayoutBuilder` with breakpoints at 600px and 900px to choose between `mobileView` / `tabletView` / `desktopView`.
- `MyHomePage` wires this to `MyHomeMobile`, `MyHomeTablet`, `MyHomeDesktop` (`lib/widget/my_home_*.dart`), each with its own tree of widgets for navigation, menus, and content display. When changing home-screen behavior, check whether the change needs to be mirrored across all three.

### Content navigation model

The 91 volumes are organized into three menu ranges reflected throughout the codebase: books 1–10 (Vinaya), 11–74 (Sutta), 75–91 (Abhidhamma) — see `lib/widget/menu/list_menu_tri1_10.dart`, `list_menu_tri11_74.dart`, `list_menu_tri75_91.dart`, and the raw title lists in `lib/widget/menu/data_menu.dart` (`book_1`, `book_2`, ... as flat Thai-title string lists per volume group). Book/page display and reading-flow widgets (formerly split across `lib/widget/showbook/`, `lib/widget/bookshow/`, `lib/widget/pageviews/`) now live together under `lib/features/book/` (multiple numbered variants: `show_book1.dart`, `show_book2.dart`, `show_book3.dart` — check which is actually wired into the current menu flow before assuming one is dead code) and dictionary entries under `lib/widget/showdict/`.

`lib/features/book/` is the first (and so far only) domain pulled out of the old `lib/widget/` split-by-type layout into a feature-first grouping. The rest of `lib/widget/` (login, search, menu, showdict, etc.) is still organized by widget type, not by feature — don't assume the whole tree follows `lib/features/*` yet.

### Theming

`ThemeProvider` (`lib/utils/theme/theme_provider.dart`) is a `ChangeNotifier` that persists/toggles both a grayscale accessibility filter (`isGrayscale`) and a dark-mode flag (`isDarkMode`), both in `SharedPreferences`. `MyApp.build()` applies the grayscale filter via a `ColorFiltered` wrapper around the whole `MaterialApp`, and sets `MaterialApp.themeMode` from `isDarkMode` (`ThemeMode.dark`/`ThemeMode.light`). Light/dark `ThemeData` objects and per-widget theme overrides live under `lib/utils/theme/` (`theme.dart`, `widget_themes/*.dart`).

### Audio

Read-aloud/speech playback goes through `lib/utils/play_audio/audio_manager.dart` (`just_audio`), with sound links resolved via remote endpoints (`tURLSoundsGetLink`, `tURLSoundsGetLinkM`) and models in `sounds_getlink.dart`.
