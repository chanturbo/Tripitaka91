# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Tripitaka91 (`tripitaka91`) is a Flutter app for reading the Thai-translated Tipitaka and commentaries (พระไตรปิฎกและอรรถกถาแปล ชุด 91 เล่ม ฉบับ มมร.) — 91 volumes of scripture text plus a Pali-Thai dictionary. The UI is entirely in Thai. Supported runtime platforms are Android, iOS, and Windows; web and macOS/Linux are explicitly unsupported at runtime (see `PlatformCheckerScreen` in `lib/main.dart`).

## Commands

```bash
flutter pub get                     # install dependencies
flutter run                         # run on a connected device/emulator
flutter run -d windows              # run the Windows desktop target
flutter test                        # run all tests
flutter test test/widget_test.dart  # run a single test file
flutter analyze                     # static analysis (flutter_lints, see analysis_options.yaml)
flutter build apk / appbundle       # Android release build
flutter build ios                   # iOS release build
flutter build windows               # Windows release build
```

Note: `test/widget_test.dart` is still the default Flutter counter-app smoke test and does not exercise this app's actual screens — treat it as a placeholder, not a source of behavioral guarantees.

## Architecture

### Bootstrapping and the bundled database

The app ships its entire content database as a **zipped SQLite file bundled as an asset** (`assets/db/tripitaka91.zip`), not fetched at runtime. On first launch:

1. `main()` (`lib/main.dart`) wraps the app in `Phoenix` (enables full app restart, used elsewhere for state resets) and a `ChangeNotifierProvider<ThemeProvider>`.
2. `PlatformCheckerScreen` branches by platform: Android/iOS/Windows → `UnzipScreen`; web → `WebNotSupportedScreen`; others → `UnsupportedPlatformScreen`.
3. `UnzipScreen` (`loadFromFuture()` in `main.dart`) copies the zip from `rootBundle` into the app's documents/support directory (path differs per platform — Android uses `.../databases`, Windows uses `getApplicationSupportDirectory()`), unzips it with `package:archive`, and stores the resulting `.db` path in `SharedPreferences` under the key `dbPath`. This only happens once; subsequent launches detect the existing `.db` file and skip re-extraction.
4. It also does an online check (`getUsersList()`) to determine an `online` flag, which is threaded down into `MyHomePage`.

`DatabaseHelper` (`lib/utils/db_helper/db_helper.dart`, singleton) opens the SQLite DB at the `dbPath` stored in `SharedPreferences` and exposes query methods per feature (dictionary search, book/title search, last-read tracking, etc.) using raw `sqflite` queries — there is no ORM layer. Most search queries build dynamic `WHERE`/`LIKE` clauses to replicate legacy PHP search behavior (including special-casing certain Thai leading vowel characters).

### Local vs. remote data

- **Local (offline-first):** book text, titles, and dictionary content are read from the bundled SQLite DB via `DatabaseHelper`. This is what makes the app usable without a network connection.
- **Remote (online features):** user accounts, login, edit-log/speech-log submissions, and some search/random-title endpoints call a PHP backend at `https://www.tripitaka91.com/workspace/`. Every endpoint URL is a constant in `lib/utils/constants/api_constants.dart` (`tURL...`). Each remote endpoint has a matching `RemoteService*` class in `lib/utils/api_connect/remote_service.dart` that does a manual `http.post` + `jsonDecode`/`jsonEncode` round trip and parses the result via a `fromJson` in the corresponding `lib/utils/models/*.dart` file. There is no shared HTTP client wrapper — each `RemoteService*` class repeats the same request/decode pattern.
- Session/user state persists via `SharedPreferences` (`lib/utils/shared_preferences/shared_user.dart`, `shared_value.dart`); `AuthenticationService.checkLoginStatus()` just checks for a stored `usersList` key.

### Responsive layout

The app has three separate layout implementations selected by screen width, not one adaptive layout:

- `ResponsiveLayoutClass` (`lib/widget/screen/respond_screen.dart`) uses a `LayoutBuilder` with breakpoints at 600px and 900px to choose between `mobileView` / `tabletView` / `desktopView`.
- `MyHomePage` wires this to `MyHomeMobile`, `MyHomeTablet`, `MyHomeDesktop` (`lib/widget/my_home_*.dart`), each with its own tree of widgets for navigation, menus, and content display. When changing home-screen behavior, check whether the change needs to be mirrored across all three.

### Content navigation model

The 91 volumes are organized into three menu ranges reflected throughout the codebase: books 1–10 (Vinaya), 11–74 (Sutta), 75–91 (Abhidhamma) — see `lib/widget/menu/list_menu_tri1_10.dart`, `list_menu_tri11_74.dart`, `list_menu_tri75_91.dart`, and the raw title lists in `lib/widget/menu/data_menu.dart` (`book_1`, `book_2`, ... as flat Thai-title string lists per volume group). Book/page display widgets live under `lib/widget/showbook/` (multiple numbered variants: `show_book1.dart`, `show_book2.dart`, `show_book3.dart` — check which is actually wired into the current menu flow before assuming one is dead code) and dictionary entries under `lib/widget/showdict/`.

### Theming

`ThemeProvider` (`lib/utils/theme/theme_provider.dart`) is a `ChangeNotifier` currently used only to persist/toggle a grayscale accessibility filter (`isGrayscale` in `SharedPreferences`), applied in `MyApp.build()` via a `ColorFiltered` wrapper around the whole `MaterialApp`. Light/dark `ThemeData` objects and per-widget theme overrides live under `lib/utils/theme/` (`theme.dart`, `widget_themes/*.dart`), though `themeMode` is currently hardcoded to `ThemeMode.light` in `main.dart`.

### Audio

Read-aloud/speech playback goes through `lib/utils/play_audio/audio_manager.dart` (`just_audio`), with sound links resolved via remote endpoints (`tURLSoundsGetLink`, `tURLSoundsGetLinkM`) and models in `sounds_getlink.dart`.
