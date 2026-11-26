# QA notes: in-progress `lib/features/book/*` changes

Found while running `/code-review` (effort: high) against the full working-
tree diff during the `log_edit` dispute-feature session (2026-11-26) — these
are **not** part of that feature. They're in your own uncommitted edits to
`lib/features/book/bookshow_title.dart`, `show_title_list.dart`,
`show_title_sub.dart`, and `pageviews_html.dart` that already existed before
that session started. Recorded here since they weren't acted on at the time
(out of scope for that piece of work) but are worth fixing.

## 1. Unguarded `indexWhere` in the new "เปิดในโหมดเว็บ" button

`lib/features/book/show_title_sub.dart` (around line 235): the new button
computes `widget.menuList.indexWhere((element) => element[0] == searchText)`
and immediately indexes `widget.menuList[index][0]`/`[1]` without checking
for `index == -1`.

**Failure scenario**: if `widget.wordSearch` doesn't exactly match any
`element[0]` in `widget.menuList` (stale navigation state, trailing
whitespace, or a menu list that no longer contains the current title),
`indexWhere` returns `-1` and `widget.menuList[-1]` throws a `RangeError`,
crashing the button's tap handler. Note the same unguarded pattern already
exists in the untouched `Icons.copy` handler nearby (around line 276) — so
this isn't a new style of bug, just a second copy of an existing one.

**Fix**: check `if (index == -1) { ...show an error/snackbar and return... }`
before indexing.

## 2. Rotor206 display-name override already expired

`lib/features/book/pageviews_html.dart` (around line 2511): shows "พระ"
instead of "นาย" for log_edit rows from user `Rotor206`, but only inside a
fixed date window `[2023-11-13, 2026-08-30)`.

**Failure scenario**: today is 2026-11-26 — already past the 2026-08-30
upper bound — so the "พระ" branch is dead for all current and future
`Rotor206` reports; they now display as "นาย" again. If the intended change
was permanent (not a temporary display window), this is already broken in
production as of now, not just a future risk.

**Fix**: decide whether this was meant to be permanent (remove the upper
bound / extend it) or genuinely temporary (then this is expected and can be
ignored).

## 3. `_openLinkInNewTab` duplicated across 3 files

The same 5-line helper (same body, same error string) was added verbatim to
`bookshow_title.dart`, `show_title_list.dart`, and `show_title_sub.dart`.

**Not a bug**, but a maintenance hazard: a future fix to its error handling
has to be applied in three separate places and will silently drift between
copies since none of them are shared. Consider extracting to a shared
helper (e.g. `lib/utils/` or a small widget) if this code is going to be
touched again.

## Status (updated 2026-11-26)

- **Fixed**: #1 (unguarded `indexWhere`) — added an `index == -1` guard with
  a snackbar before indexing, in the new "เปิดในโหมดเว็บ" button only (the
  pre-existing copy/share buttons a few lines below have the same latent
  issue but were left as-is, unchanged by this fix).
- **Fixed**: #3 (`_openLinkInNewTab` triplicated) — extracted to
  `lib/utils/launch_url/launch_url.dart` (top-level `openLinkInNewTab`),
  removed the three private copies and their now-unused `url_launcher`
  imports from `bookshow_title.dart`, `show_title_list.dart`,
  `show_title_sub.dart`. `flutter analyze` clean after the change.
- **#2 — real one-day discrepancy found, now fixed on both sides
  (2026-11-26)**: the Rotor206 "พระ"/"นาย" display-name date window
  reflects the user's actual ordination period — ordained 13 November 2023,
  **ordained up to and including 29 August 2026** (confirmed explicitly by
  the user). This logic is duplicated in two places:
  - `lib/features/book/pageviews_html.dart` (~line 2506, this repo)
  - `tri91_process.php` in
    `D:\WebTripitaka91\tripitaka91-site\ไฟล์ PHP index\` (lines 96-113) —
    the public website's own copy of this same check, a **different
    location from `public_site/workspace/`**, not otherwise touched this session.

  They originally disagreed by one day: the website used
  `$targetDate2 = strtotime('2026-08-29')` with `$dateAdd < $targetDate2`
  (so 29 Aug itself already showed "นาย"), while the app used
  `targetDate2 = DateTime(2026, 8, 30)` (so 29 Aug showed "พระ"). The user
  clarified 29 Aug should be the **last day still shown as "พระ"**, i.e. the
  app's original behavior was correct — so the website was the one that
  needed to change. Fixed `tri91_process.php` to
  `$targetDate2 = strtotime('2026-08-30');` to match the app exactly. The
  app's own value was reverted back to `DateTime(2026, 8, 30)` (its original,
  correct value — an earlier pass in this same session had briefly "fixed"
  it the wrong way, to Aug 29, before this clarification; that was reverted).
  Both now agree: a report dated 29 Aug 2026 shows "พระ" in both the app and
  the website; 30 Aug 2026 onward shows "นาย" in both.

## 4. `Tri91BookAll.fromJson`/`fromMap`: only string fields got null-guards

Found 2026-11-26 in a follow-up `/code-review` pass (effort: high, target
`origin/iosx`) — a different, still-outstanding finding in the same
in-progress work, not yet fixed.

`lib/utils/models/tri91_bookall.dart` (~line 70): the factory was updated
with null-coalescing for string fields (`bookTitleTri`, `bookDetail`, etc. —
presumably because `showbookall.php`'s `SELECT *` can return NULL for those
columns), but the sibling **int** fields in the same factory —
`bookPagesTotal`, `bookReadall`, `bookLastPages`, `bookLastLine` — were left
unguarded.

**Failure scenario**: if any book row has NULL in one of those int columns
(e.g. metadata not fully populated yet for a given book), parsing throws
`type 'Null' is not a subtype of type 'int'` and the book info screen
crashes, the same class of bug the string-field fix was presumably written
to prevent, just not applied consistently across the whole factory.

**Fix**: add the same `?? <default>` treatment to the four int fields.

## 5. "เปิดในโหมดเว็บ" button duplicated between mobile and tablet/desktop layouts

Found in the same pass. `lib/features/book/bookshow_title.dart` (~line 756):
the same `Tooltip`/`IconButton` block for this button is duplicated
byte-for-byte between the mobile layout branch and the tablet/desktop
layout branch.

**Not a bug**, but the same maintenance hazard as #3 above, for a block
that wasn't part of that cleanup: a future change to this button (URL
format, icon, tooltip) has to be made in two places and can silently drift
between mobile and desktop.

## 6. Space-character indentation for Pitaka category headers

Found in the same pass. `lib/features/book/pageviews_html.dart` (~line 2391):
header indentation between Vinaya/Abhidhamma vs. Sutta categories is done
by prepending literal repeated space characters (`' ' * 10` vs `' ' * 8`) to
the `TextSpan` text, instead of using layout padding.

**Failure scenario**: with a proportional (non-monospace) font, a fixed
count of space characters doesn't correspond to a fixed pixel width — it
varies with font, font size, and the device's text-scale setting — so the
intended alignment between these headers can drift or invert depending on
device/accessibility settings. A `Padding`/`Container`-based indent would be
exact regardless of font metrics.

**Fix**: not done — flagging for your judgment, since it's cosmetic and
you may already know how it renders on your target devices.

## Status: #4, #5, #6 — fixed (2026-11-26, on request)

- **Fixed #4**: added `?? 0` to `bookPagesTotal`, `bookReadall`,
  `bookLastPages`, `bookLastLine` in both `Tri91BookAll.fromMap` and
  `.fromJson` (`lib/utils/models/tri91_bookall.dart`).
- **Fixed #5**: extracted the duplicated block into
  `_buildOpenWebModeButton(BuildContext context)` on `_BookShowTitleState`
  (`lib/features/book/bookshow_title.dart`), called from both the mobile
  and tablet/desktop layout branches instead of each having its own copy.
- **Fixed #6**: replaced the repeated-space-character prefix with a
  `WidgetSpan(child: SizedBox(width: headerIndent * _fontSize * <multiplier>))`
  inserted before the header `TextSpan`, in `lib/features/book/pageviews_html.dart`
  (~line 2390) — gives an exact, font-independent pixel width instead of a
  character count, while keeping the same relative size difference between
  the two indent levels (10 vs 8 "เคาะ"). Multiplier iterated by direct user
  feedback after seeing it rendered: `0.5` (initial) → `0.8` (user asked to
  shift in more — misread as "indent further right") → **`0.25`** (user
  clarified they meant the opposite: pull back toward the left margin,
  current/final value shifts noticeably further left than even the
  original `0.5`).

`flutter analyze` clean across the whole project after all three fixes.

## 7. "รายงานคำที่น่าจะผิด" dialogs didn't show the reporter's หมายเหตุ (comment)

Found 2026-11-26 while investigating a user-reported "blank dialog" for
user `Rotor206` (the monk account from #2 above — not `Rotor9` as the user
first guessed; that username doesn't exist). Checked the database: of all
84,917 `log_edit` rows, 622 have blank/placeholder (e.g. a single space or
`-`) `tripitaka91_wordincorrect`/`tripitaka91_wordcorrect` — **600 of those
622 (96%) are from `Rotor206` alone**, who habitually writes the real
explanation in `tripitaka91_wordcorrectcomment` instead (often a full
dictionary-style note), which neither dialog displayed at all. Not a bug in
either dialog's logic — the underlying data is genuinely blank in those two
fields; the comment is where the actual content lives.

**Fixed, both dialogs now show the comment when present:**
- `lib/features/book/pageviews_html.dart`'s "รายงานคำที่น่าจะผิด" popup
  (shown while reading a page) — added `comment` to `_WordReportEntry`,
  populated from `log.tripitaka91Wordcorrectcomment` (already fetched by
  `show_logedit.php`'s `SELECT log_edit.*`, just never read), shown as an
  italic "หมายเหตุ: ..." line per entry when non-empty.
- `lib/widget/login/show_logedit_save.dart`'s "ดูรายชื่อผู้แจ้ง" dialog
  (`_showDialogUserCorrect`) — this one's backing endpoint,
  `public_site/workspace/showuserinpagecorrect.php`, only ever selected
  `users.*` plus a converted date, no `log_edit` word/comment columns at
  all. Added `log_edit.tripitaka91_wordincorrect`,
  `tripitaka91_wordcorrect`, `tripitaka91_wordcorrectcomment` to its
  `SELECT`, and updated the dialog's `ListTile.subtitle` (now a `Column`)
  to show the word pair and comment per reporter when present.

`flutter analyze` clean after both. The PHP change is in
`public_site/workspace/` — same deployment caveat as everything else
there: not live until uploaded.

## 8. Same "รายงานคำที่น่าจะผิด" dialog — sizing and readability, user-requested

Two more direct requests on this same dialog (`_showAnnotationDialog` in
`pageviews_html.dart`), both fixed 2026-11-26:

- **Width/height**: was `SizedBox(width: double.maxFinite)` with no height
  bound — looked close to full-screen-wide and, on a first pass, was given
  a *fixed* height (`(screenHeight * 0.6).clamp(200, 550)`) which then left
  a lot of empty space for short reports. Final fix: `SizedBox(width:
  (screenWidth * 0.85).clamp(0, 450))` for width only, no forced height —
  `AlertDialog` already wraps its `content` in its own internal
  `SingleChildScrollView`/`Flexible`, so removing the extra inner
  `SingleChildScrollView` this dialog had added let it hug short content
  and still scroll/cap at the screen size for long content, for free.
- **Color coding**: in `_reportInfoRowPair` (used to render "คำที่น่าจะผิด: X
  คำที่น่าจะถูก: S"), the `X` value is now red and the `S` value green
  (both bold), matching the red/green convention already used for the old
  text vs. corrected-text `SelectableText` further down in the same dialog.

`flutter analyze` clean after each step.
