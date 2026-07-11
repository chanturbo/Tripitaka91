# Porting these fixes to other platform branches/checkouts

This documents the fixes made on the `iosx` branch in this session (started 2026-07-11),
so the same fixes can be applied to your other platform checkouts (`main`, `androidx`,
`android`, `offline`, or any other repo sharing this codebase).

**Status on `iosx`:**
- Commit `cec9201` ("Fix leaked signing key, connectivity bug, and all flutter analyze
  warnings") — security fix + full lint cleanup (section 1–2 below). **Committed.**
- Everything from section 3 onward (project restructuring, dark mode, theme-awareness,
  home-screen consolidation) — **not committed yet**, still sitting in the working tree.
  Commit that on `iosx` first, then use this doc to port to the others.

## 0. Check how close your other branch already is

Before manually redoing anything, check how far the target branch has drifted from `iosx`:

```bash
git diff --stat iosx origin/<branch> -- lib/
```

Re-run this fresh before porting — the numbers below are from *before* section 3 onward
landed, so `iosx` has drifted further from `android`/`androidx`/`offline` since then
(new files, moved files, renamed symbols). Don't assume the old "near-identical" read
still holds without rechecking.

- `androidx`, `android`, `offline` were **near-identical** to `iosx` as of commit
  `cec9201` (~46 files, a few hundred lines of diff) — for the security/lint fixes,
  prefer `git cherry-pick cec9201` or `git merge iosx`. For the restructuring work
  (sections 3+), check the diff again first — a straight cherry-pick will conflict on
  every file that got moved to `lib/features/book/` or touched by the theme-helpers sweep.
- `main` had **diverged significantly** even before this session (73 files, thousands of
  lines different) — always reapply manually via the checklists below, don't attempt
  cherry-pick/merge.

## 1. Security — already fixed everywhere, nothing to port

These are **not per-branch fixes** — don't redo them:

- The Android upload keystore (`android/app/upload-keystore.jks`) password was rotated
  in place (it's the same physical file/signing key referenced from every branch/checkout
  on this machine, not something checked into git). Old password `tripitaka91` no longer
  works; the new one lives in each checkout's local, gitignored `key.properties`.
- `key.properties` was purged from git history on `android`, `androidx`, `iosx`, `offline`
  (force-pushed to GitHub already). `main` never had it.
- `.gitignore` now excludes `key.properties`, `*.jks`, `*.keystore` — make sure this line
  exists on every branch (add it manually if a branch's `.gitignore` predates this fix):
  ```
  key.properties
  *.jks
  *.keystore
  ```
- If a checkout still has the *old* `key.properties` (with `storePassword=tripitaka91`),
  overwrite it with the new password — do not regenerate/rotate again, just copy the
  working `key.properties` from the `iosx` checkout.

## 2. Lint fixes — apply per branch (`flutter analyze` should go from ~122 issues to 0)

Run `flutter analyze` on the target branch first to see its actual count/locations —
line numbers (and even file paths — see section 3) will differ from `iosx`. The
categories below are your checklist; the `iosx` commit `cec9201` is your reference
implementation for each pattern.

### 2.1 `avoid_print` — remove/replace stray `print()`
- Pure debug-trace `print(...)` calls with no error-recovery value: delete the whole
  statement.
- `print(...)` inside a `catch (e)` block (genuine error logging): rename to
  `debugPrint(...)` (needs `import 'package:flutter/foundation.dart';`).
- All 22 instances in this session were in `lib/utils/db_helper/db_helper.dart`.

### 2.2 `strict_top_level_inference` — add explicit return types
- Widget-returning private methods with no return type → add `Widget`.
- `void`-returning methods with no return type → add `void`.
- `async` methods with no return value → add `Future<void>`.
- Files hit: `login/loading_dialog.dart`, `login/login.dart`, `login/login_dialog.dart`,
  `my_home_tablet.dart`, `pageviews/pageviews_html.dart`.

### 2.3 `withOpacity` → `withValues`
Mechanical, safe to do with sed across the whole `lib/` tree:
```bash
for f in $(grep -rl '\.withOpacity(' lib/ --include="*.dart"); do
  sed -i '' -E 's/\.withOpacity\(([0-9.]+)\)/.withValues(alpha: \1)/g' "$f"
done
```
(On Linux, drop the `''` after `-i`.) 16 call sites fixed this way in this session.

### 2.4 `use_null_aware_elements`
```dart
// before
if (searchText != null) 'searchText': searchText,
// after
'searchText': ?searchText,
```

### 2.5 `await_only_futures`
`ArchiveFile.content` (package:archive) is synchronous — drop the stray `await`:
```dart
// before
final data = await file.content as List<int>;
// after
final data = file.content as List<int>;
```

### 2.6 `use_build_context_synchronously` — the important one (crash risk)
Add a mounted guard **immediately after the last `await`** and before the next use of
`context`, for every flagged line. Which guard to use is not always predictable from
structure alone — try one, and let `flutter analyze`'s diagnostic tell you which it wants:

- Inside a `State<T>` method, using the State's own `context` (e.g. `build`'s own
  `context` parameter, not a nested builder's): use `if (!mounted) return;`
- Any other `BuildContext` (an explicit `BuildContext context` function parameter, or a
  `context` from a nested `itemBuilder`/`builder` callback that shadows the outer one, or
  a non-`State` class like `SearchDelegate`): use `if (!context.mounted) return;`
- For a `.then((value) { ... })` callback using `context`, prefer rewriting to
  `await`/`async` first — the analyzer's mounted-check pattern matching doesn't reliably
  recognize guards inside `.then()` closures.

29 sites fixed in this session across: `main.dart`, `bookshow_title.dart`,
`login/change_password_dialog.dart`, `login/show_logcorrect.dart`,
`login/show_logedit_save.dart`, `login/show_logedit_save_with_page.dart`,
`login/show_member.dart`, `login/show_speech_save.dart`, `login/signup_screen.dart`,
`search/data_search_widget.dart`.

### 2.7 `Share`/`Share.shareXFiles` → `SharePlus.instance.share(ShareParams(...))`
`share_plus: ^12.0.1` deprecated the static `Share` class. Mapping:
```dart
// before
await Share.share(text, subject: subject);
// after
await SharePlus.instance.share(ShareParams(text: text, subject: subject));

// before
await Share.shareXFiles([XFile(path)], text: text);
// after
await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: text));
```
15 call sites fixed in this session: `bookshow_title.dart` (x2), `show_title_sub.dart`
(x2), `search/search_show_dict.dart`, `search/search_show_dictbt.dart`,
`showdict/show_dict_list.dart`, `showdict/show_dict_list_2.dart`,
`showdict/show_dictbt_list.dart`, `showdict/show_dictbt_list_2.dart`,
`pageviews.dart` (x2), `pageviews_html.dart` (x2),
`utils/img_service/img_service.dart` (shareXFiles).

### 2.8 `Radio` `groupValue`/`onChanged` → `RadioGroup` ancestor
Flutter deprecated per-`Radio`/`RadioListTile` `groupValue`/`onChanged` in favor of a
`RadioGroup<T>` ancestor wrapping all the radios in that group:
```dart
// before
RadioListTile<bool>(value: true, groupValue: x, onChanged: (v) => setState(() => x = v!)),
RadioListTile<bool>(value: false, groupValue: x, onChanged: (v) => setState(() => x = v!)),

// after
RadioGroup<bool>(
  groupValue: x,
  onChanged: (v) => setState(() => x = v!),
  child: Column(
    children: [
      RadioListTile<bool>(value: true),
      RadioListTile<bool>(value: false),
    ],
  ),
),
```
Fixed in `widget/appbar/app_bar.dart` and `widget/login/set_voice.dart` this session —
check other branches for additional `Radio`/`RadioListTile` usages that may not exist
on `iosx`.

## 3. Project restructuring — `lib/features/book/` (not committed yet on `iosx`)

11 files moved out of three type-based folders into one feature folder, via `git mv`
(preserves history) plus an import-path rewrite in every file that referenced them
(26 files total). Path mapping for other branches:

| Old path | New path |
|---|---|
| `lib/widget/bookshow/bookshow_title.dart` | `lib/features/book/bookshow_title.dart` |
| `lib/widget/bookshow/show_title_list.dart` | `lib/features/book/show_title_list.dart` |
| `lib/widget/bookshow/show_title_sub.dart` | `lib/features/book/show_title_sub.dart` |
| `lib/widget/showbook/show_book.dart` | `lib/features/book/show_book.dart` |
| `lib/widget/showbook/show_book1.dart` | `lib/features/book/show_book1.dart` |
| `lib/widget/showbook/show_book2.dart` | `lib/features/book/show_book2.dart` |
| `lib/widget/showbook/show_book3.dart` | `lib/features/book/show_book3.dart` |
| `lib/widget/showbook/show_title.dart` | `lib/features/book/show_title.dart` |
| `lib/widget/pageviews/pageviews.dart` | `lib/features/book/pageviews.dart` |
| `lib/widget/pageviews/pageviews_edit.dart` | `lib/features/book/pageviews_edit.dart` |
| `lib/widget/pageviews/pageviews_html.dart` | `lib/features/book/pageviews_html.dart` |

To port: same `git mv` + then mechanically rewrite import paths:
```bash
mkdir -p lib/features/book
git mv lib/widget/bookshow/bookshow_title.dart lib/features/book/bookshow_title.dart
# ...repeat for the other 10 files, then:
rmdir lib/widget/bookshow lib/widget/showbook lib/widget/pageviews  # once empty

for f in $(grep -rl "widget/bookshow/\|widget/showbook/\|widget/pageviews/" lib/ --include="*.dart"); do
  sed -i '' \
    -e "s#package:tripitaka91/widget/bookshow/#package:tripitaka91/features/book/#g" \
    -e "s#package:tripitaka91/widget/showbook/#package:tripitaka91/features/book/#g" \
    -e "s#package:tripitaka91/widget/pageviews/#package:tripitaka91/features/book/#g" \
    "$f"
done
```
Verify with `flutter analyze` afterward — it will surface any import it missed. This
was the only folder touched; the rest of `lib/widget/` (login, search, menu, showdict,
etc.) is still organized by type, not by feature.

## 4. Dark mode + theme-awareness (not committed yet on `iosx`)

### 4.1 Enabling dark mode
- `lib/utils/theme/theme_provider.dart`: `ThemeProvider` gained `isDarkMode` +
  `toggleDarkMode()`, persisted via `SharedPreferences` key `isDarkMode` (same pattern as
  the existing `isGrayscale`).
- `lib/main.dart`: `MaterialApp.themeMode` now reads
  `themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light` instead of being hardcoded
  to `ThemeMode.light`. No `Phoenix.rebirth()` needed — `context.watch<ThemeProvider>()`
  triggers Flutter's own theme rebuild.
- A toggle `IconButton` (🌙/☀️, `Icons.dark_mode`/`Icons.light_mode`) was added next to the
  existing grayscale toggle in the AppBar `actions` of `my_home_mobile.dart`,
  `my_home_tablet.dart`, `my_home_desktop.dart` — same tooltip/onPressed pattern as the
  grayscale button, just calling `toggleDarkMode()`.
- **Bug fixed in `lib/utils/theme/theme.dart`**: `darkTheme.drawerTheme.backgroundColor`
  was `TColors.white` — identical to the light theme's, a copy-paste leftover from when
  dark theme was defined but never actually reachable. Changed to `TColors.black`.

### 4.2 `lib/utils/theme/theme_helpers.dart` (new file) — the important part
Enabling the dark-mode switch is not enough by itself: **117 places across `lib/widget/`
hardcoded `Colors.white`/`TColors.white`/`Colors.black` directly in widget code**
instead of reading from `Theme.of(context)`, so most of the app stayed visually stuck in
light mode even with the switch flipped. This file provides the fix pattern:

```dart
Color adaptiveSurfaceColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? TColors.black : Colors.white;

Color adaptiveBorderColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? TColors.white : Colors.black;

Color adaptiveTextColor(BuildContext context) => adaptiveBorderColor(context);
```

**Only 32 of the 117 sites actually needed changing** — the other 85 are white/black
text or icons sitting on a *fixed*-color badge/button (e.g. white text on a permanent
`Colors.blue[900]` CircleAvatar, or AppBar icons that stay white against the AppBar's
own always-dark background in both themes) and are correct as-is. Use this rule when
triaging another branch:
- **Fix it** (swap for the adaptive helper) if the color is a *page-like surface*
  (a panel/card/container background) or *general readable text* not sitting on a
  fixed-color badge.
- **Leave it** if it's text/an icon drawn on a background that is itself a fixed,
  non-theme color (a colored button, a colored avatar, a colored status chip).
- Watch for `const` — injecting `adaptiveSurfaceColor(context)` etc. into a `const
  BorderSide(...)`/`const TextStyle(...)`/`const Icon(...)` requires dropping the
  `const` keyword, or you get a compile error. (Learned this the hard way: a first
  attempt to batch this with a sed/Python script broke `const BorderSide` in 3 files
  with cascading parse errors — reverted via `git checkout` and redone with verified,
  non-scripted edits. If you script this on another branch, test on one file first and
  run `flutter analyze` before applying broadly.)

Files touched (all needed `import 'package:tripitaka91/utils/theme/theme_helpers.dart';`
added): `my_home_tablet.dart`, `my_home_desktop.dart`, `widget/appbar/app_bar.dart`,
`widget/search/screen_mobile.dart`, `widget/card/title_card.dart`,
`widget/search/search_tab_show.dart`, `widget/login/show_speech_save.dart`,
`widget/login/show_logedit_save.dart`, `widget/login/show_logedit_save_with_page.dart`,
and 6 near-duplicate search-result files: `search_show_tri91_onpage.dart`,
`search_show_tri91.dart`, `search_show_titlerandom.dart`, `search_show_title.dart`,
`search_show_dictbt.dart`, `search_show_dict.dart` (all the same one-line fix: the
`SubstringHighlight`/`TextStyle` result-text color).

### 4.3 Other UI cleanup bundled into this pass
- `app_bar.dart` ONLINE/OFFLINE toggle: hardcoded `Colors.blue`/`Colors.red` → `TColors
  .info`/`TColors.error`; the old 3-breakpoint nested-ternary label
  (`"ONLINE"`/`"เปิด ONLINE"`/`"เปิดเวอร์ชั่น ONLINE"`) collapsed to one label
  (`"เปิด ONLINE"`/`"ปิด ONLINE"`) plus a podcast icon, same across all screen sizes.
- New `AResponsiveTitleText` widget in `widget/auto_text/auto_text.dart` replaces the
  repeated `(!isTablet && !isDesktop) ? ATextTitleMedium18(...) : ATextTitleMedium(...)`
  ternary in `list_menu.dart` (x2), `sub_menu_book.dart` (x1), `sub_menu_title.dart` (x2).
  Left a few near-matches alone where the ternary's non-mobile branch used a *different*
  widget (`ATextBodyMedium`, plain `Text`) — porting this, check each site's non-mobile
  branch before assuming it's a drop-in replacement.

## 5. Home-screen logic consolidation — `HomeStateMixin` (not committed yet on `iosx`)

`my_home_mobile.dart` / `my_home_tablet.dart` / `my_home_desktop.dart` had ~140 lines of
byte-for-byte duplicated state and logic each (random-title fetching, login-status
check, the "open from URL query params" timer, dispose/logout) — only their `build()`
methods (drawer vs. icon-rail vs. permanent panel — genuinely different navigation UX,
deliberately **not** touched) actually differ.

New file `lib/widget/home_state_mixin.dart` — `mixin HomeStateMixin<T extends
StatefulWidget> on State<T>` holding all the shared fields/methods. Each of the three
`_MyHomeXState` classes now does:
```dart
class _MyHomeMobileState extends State<MyHomeMobile> with HomeStateMixin<MyHomeMobile> {
  @override
  bool get online => widget.online;
  @override
  bool get isMobileLayout => true; // false for tablet/desktop
  // ...build() unchanged...
}
```
Note: formerly-private mixin members (`_onTimerFinished`, `_checkLoginStatus`,
`_checkArguments`, `_timer`) had to be renamed without the leading underscore
(`onTimerFinished`, `checkLoginStatus`, `checkArguments`, `homeTimer`) — Dart privacy is
per-*file*, so a `State` class in a different file than the mixin can't see its private
members even though it's mixed in. Update each `build()`'s `onPressed: _checkLoginStatus`
call site to the renamed `checkLoginStatus` accordingly.

Also found and dropped as genuinely dead code while doing this: `sidebarButtonNo` was
declared in `my_home_mobile.dart`'s state but never read/written anywhere in that file
(leftover from copy-pasting tablet's state) — don't be surprised if another branch has
the same unused field; safe to drop, not safe to assume it's *always* dead without
checking that branch's own `my_home_mobile.dart`.

## 6. Other bug fixes worth porting (found during review, not lint- or restructure-driven)

- **`main.dart` `online` flag**: was computed from a cached local login (`getUsersList()`),
  not real connectivity — silently wrong for "has internet but never logged in" and
  "logged in before but now offline" cases. Fixed by probing `tURLmain` with a 5s timeout
  instead. Check whether other branches have the same bug in their `_startUnzippingProcess`.
- **`app_bar.dart` online-flag inverted**: the "enable ONLINE reading-aloud mode" toggle
  was gated `widget.online ? const SizedBox.shrink() : InkWell(...)` — hiding the button
  exactly when there *was* internet and showing it exactly when there wasn't (backwards,
  since the feature needs internet to work). One-character fix: `!widget.online ? ... `.
  This bug only became *visible* after the `main.dart` connectivity fix above changed
  what `online` actually means — check whether other branches have the same inverted
  condition once you've ported that fix, since it may have been silently masked there too.

## 7. Verify after porting

```bash
flutter analyze   # should report 0 issues
flutter test test/widget_test.dart   # will still fail — it's Flutter's unmodified
                                      # counter-app template test (checks for a "0"/"1"
                                      # counter and a "+" button that don't exist in this
                                      # app), unrelated to any of the above
```
