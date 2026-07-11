# Porting these fixes to other platform branches/checkouts

This documents the fixes made on the `iosx` branch in this session (2026-07-11), so the
same fixes can be applied to your other platform checkouts (`main`, `androidx`, `android`,
`offline`, or any other repo sharing this codebase). Status here: **all fixes below are
made but not committed** on `iosx` — commit them there first, then use the guidance below
to port to the others.

## 0. Check how close your other branch already is

Before manually redoing anything, check how far the target branch has drifted from `iosx`:

```bash
git diff --stat iosx origin/<branch> -- lib/
```

In this session:
- `androidx`, `android`, `offline` were **near-identical** to `iosx` (~46 files, a few
  hundred lines of diff, mostly platform-specific tweaks) — for these, prefer
  `git cherry-pick <commit>` or `git merge iosx` once the fixes are committed, and only
  fall back to manual reapplication where it conflicts.
- `main` had **diverged significantly** (73 files, thousands of lines different) — a
  direct cherry-pick/merge will likely conflict heavily. Use the checklist below to
  manually reapply each category instead.

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

## 2. Code fixes — apply per branch (`flutter analyze` should go from ~122 issues to 0)

Run `flutter analyze` on the target branch first to see its actual count/locations —
line numbers will differ from `iosx`. The categories below are your checklist; the
`iosx` commit is your reference implementation for each pattern.

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

29 sites fixed in this session across: `main.dart`, `bookshow/bookshow_title.dart`,
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
15 call sites fixed in this session, listed here for reference:
`bookshow/show_title_sub.dart` (x2), `bookshow/bookshow_title.dart` (x2),
`search/search_show_dict.dart`, `search/search_show_dictbt.dart`,
`showdict/show_dict_list.dart`, `showdict/show_dict_list_2.dart`,
`showdict/show_dictbt_list.dart`, `showdict/show_dictbt_list_2.dart`,
`pageviews/pageviews.dart` (x2), `pageviews/pageviews_html.dart` (x2),
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

## 3. Also worth porting (found during review, not lint-driven)

- **`main.dart` `online` flag**: was computed from a cached local login (`getUsersList()`),
  not real connectivity — silently wrong for "has internet but never logged in" and
  "logged in before but now offline" cases. Fixed by probing `tURLmain` with a 5s timeout
  instead. Check whether other branches have the same bug in their `_startUnzippingProcess`.

## 4. Verify after porting

```bash
flutter analyze   # should report 0 issues
flutter test test/widget_test.dart   # will still fail — it's Flutter's unmodified
                                      # counter-app template test, unrelated to this app
```
