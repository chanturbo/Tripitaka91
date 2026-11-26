# Dispute/revert workflow for applied typo corrections

Status as of 2026-11-26. Implemented per the plan the user approved this
session (full plan text also available in this session's plan file; this
doc is the durable record). Companion to `LOG_EDIT_REVIEW_RECOMMENDATIONS.md`
(this closes that doc's recommendation #3, "no audit trail") and
`LOG_EDIT_IMPORT_WORKFLOW.md`.

## What this adds

Previously, once a typo correction was applied via `confirm_correct.php`
(overwriting `tripitaka91_91book_line.book_detail`), there was no backup and
no way for anyone to flag a bad fix. Now:

- Every apply snapshots the before/after text into a new `log_edit_history`
  table.
- Any logged-in member viewing an already-applied correction
  (`booksuscess==1`, the "แก้ไขแล้ว" filter in `ShowCorrectSave`) can tap
  "แจ้งว่าการแก้ไขนี้ไม่ถูกต้อง" and submit a reason — stored in a new
  `log_edit_dispute` table.
- A new admin-only screen ("ตรวจสอบข้อโต้แย้งการแก้ไข", gated by
  `levelAccess=='1'`, reached from the admin-tools section of a user's own
  profile page) lists pending disputes grouped by line and lets the admin
  **revert** (restore the pre-fix text from `log_edit_history`, reset the
  line back to "ยังไม่ยืนยัน" so it can collect fresh proposals) or **reject**
  (dismiss the dispute, fix stands) — resolving every pending dispute on
  that line at once.

Also bundled in (same file/feature area, separately decided by the user):
`tCorrectNum` (the number of member confirmations required before the
"ยืนยันการแก้ไขข้อมูล" apply button appears) changed from `10` to `1` in
`lib/utils/constants/api_constants.dart`.

## New tables (already created on production)

```sql
CREATE TABLE `log_edit_history` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `tripitaka91_book` INT(11) NOT NULL,
  `tripitaka91_page` INT(11) NOT NULL,
  `tripitaka91_line` INT(11) NOT NULL,
  `book_detail_before` VARCHAR(150) NOT NULL,
  `book_detail_old_before` VARCHAR(255) DEFAULT NULL,
  `book_detail_after` VARCHAR(150) NOT NULL,
  `applied_by` VARCHAR(150) NOT NULL DEFAULT 'system',
  `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `source` VARCHAR(30) NOT NULL DEFAULT 'admin_confirm',
  `reverted_at` TIMESTAMP NULL DEFAULT NULL,
  `reverted_by` VARCHAR(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_log_edit_history_line` (`tripitaka91_book`, `tripitaka91_page`, `tripitaka91_line`, `applied_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `log_edit_dispute` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `tripitaka91_book` INT(11) NOT NULL,
  `tripitaka91_page` INT(11) NOT NULL,
  `tripitaka91_line` INT(11) NOT NULL,
  `tripitaka91_user` VARCHAR(150) NOT NULL,
  `tripitaka91_comment` TEXT NOT NULL,
  `tripitaka91_ip` VARCHAR(50) DEFAULT NULL,
  `tripitaka91_dateadd` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `status` TINYINT(1) NOT NULL DEFAULT 0,
  `resolved_by` VARCHAR(150) DEFAULT NULL,
  `resolved_at` TIMESTAMP NULL DEFAULT NULL,
  `history_id` INT(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_log_edit_dispute_line` (`tripitaka91_book`, `tripitaka91_page`, `tripitaka91_line`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

`log_edit_dispute.status`: `0`=pending, `1`=resolved-by-revert, `2`=resolved-by-reject.
`log_edit_history`: "what to restore" is always the newest row for that line
with `reverted_at IS NULL`. Naming deliberately follows `log_edit`'s column
style (`tripitaka91_book/page/line`), not `tripitaka91_91book_line`'s
(`book_id/book_pages/book_lines`) — see the approved plan for why.

These two tables are forward-compatible with the still-paused bulk-apply
tool documented in `LOG_EDIT_BULK_REVIEW.md` (`tools/log_edit_bulk_review/`):
when that eventually runs, it should write its applies into `log_edit_history`
too (`source='bulk_auto_apply'`) so both apply paths share one audit trail
and are both revertible through the same dispute screen.

## Files changed/added

- `public_site/workspace/confirm_correct.php` — now takes a `username` POST field and
  writes a `log_edit_history` row (reading the *current* `book_detail`
  straight from `tripitaka91_91book_line`, not the possibly-stale
  `log_edit.book_detail_old`) before its existing overwrite.
- New: `public_site/workspace/save_logedit_dispute.php`, `show_logedit_dispute_withall.php`,
  `resolve_logedit_dispute.php`.
- `lib/utils/constants/api_constants.dart` — `tCorrectNum` 10→1, plus 3 new
  `tURL*` constants for the endpoints above.
- `lib/widget/login/show_logedit_save.dart` — new dispute button/dialog
  (card view: third status tag when `booksuscess==1`; list view: new popup
  menu item), `username` now sent to `confirm_correct.php`.
- New: `lib/widget/login/show_logedit_dispute.dart` (`LogEditDisputePage`,
  the admin review screen — mirrors `show_userall.dart`'s structure).
- `lib/widget/login/show_member.dart` — one new `_ActionButton` in the
  existing admin-tools block, pushing `LogEditDisputePage`.

## Deployment status — IMPORTANT

**The two tables were created directly on the production database** (same
dev-tunnel connection documented in `LOG_EDIT_BULK_REVIEW.md`: MariaDB
10.6.20, `tripitaka91_dbnew` at `45.91.133.62:33062`) — this part is live.

**The PHP changes are NOT deployed.** Same situation as the earlier
`confirm_correct.php` NULL-guard fix noted in
`LOG_EDIT_REVIEW_RECOMMENDATIONS.md`: this repo's `public_site/workspace/` is a local
staging copy, not auto-deployed to `https://www.tripitaka91.com/workspace/`.
The user needs to upload the modified `confirm_correct.php` and the three
new PHP files themselves before any of this works against the real site.
The Flutter app changes will silently fail (snackbar showing a PHP/HTTP
error) against the live backend until that upload happens.

## Verification done this session

No PHP interpreter available locally new enough to run these files (the
only local `php` is 5.2.6, can't even parse this codebase's pre-existing
files — short array syntax alone fails `php -l` on untouched files). Instead:

- `flutter analyze` on the whole project: clean, no issues.
- Every new/changed SQL statement was manually run, in sequence, directly
  against the production DB using a disposable synthetic test row
  (`book_id=9999`, cleaned up afterward — nothing real was touched):
  apply → history row written correctly, `book_suscess=1`; two different
  users dispute the same line → both guards worked, grouped-list query
  returned one group with `dispute_count=2`; revert → `book_detail`
  restored from history, history row marked consumed, `book_suscess=0` +
  `book_confirm=0` + `log_edit_confirm` cleared, both disputes resolved
  together; reject path and the "no un-reverted history row" blocked-revert
  edge case were also exercised and behaved as designed.
- **Not done**: interactive testing of the actual Flutter UI (would need a
  running device/emulator and logged-in test accounts at both permission
  levels) and the actual PHP endpoints over HTTP (blocked on the deployment
  step above). Both are recommended before considering this fully verified.

## QA pass (2026-11-26, same session)

Ran `/code-review` (effort: high) against the full working-tree diff. It
also surfaced findings in files unrelated to this feature — those are from
the user's own pre-existing uncommitted edits to `lib/features/book/*`
(already modified before this session started, per the session's initial
`git status`) and were left untouched; only the findings about this
feature's own new/changed files were acted on:

- **Fixed**: `resolve_logedit_dispute.php` / `save_logedit_dispute.php` —
  catch blocks called `$conn->rollBack()` even if `$conn` was never assigned
  (e.g. `new Database()` itself throwing); now guarded with
  `if ($conn && $conn->inTransaction())`.
- **Fixed**: `show_logedit_dispute_withall.php` — added
  `SET SESSION group_concat_max_len = 20000` before the grouped query, since
  the default (1024 on many installs) could silently truncate the
  concatenated dispute comments shown to the admin.
- **Fixed**: `show_logedit_save.dart`'s new `_fetchSubmitDispute` and
  `show_logedit_dispute.dart`'s new `_fetchResolveDispute` were missing
  `if (!mounted) return;` after their `await http.post(...)` calls before
  touching `context` (present on `_fetchDataCorrect` in the same file but
  not on several of its older siblings — added it to the new code rather
  than leaving it inconsistent). Same fix in `_showDisputeDialog`'s submit
  button (`if (!context.mounted) return;` before `Navigator.pop()`).
- **Accepted, not changed** (already known/decided before writing the code):
  no server-side `levelAccess` check on `resolve_logedit_dispute.php` —
  matches `confirm_correct.php`/`update_logedit_confirm.php`'s existing
  client-only gating, called out explicitly in the approved plan as a
  pre-existing gap, not this feature's to fix. Likewise the inline
  `http.post`-in-widget style instead of a `RemoteService*` class — a
  deliberate choice to match this exact feature area's actual convention
  (see the approved plan).
- **Fixed (2026-11-26, follow-up)**: `confirm_correct.php`'s `$folderCreator`
  MP3-cleanup call was never instantiated anywhere in the file — pre-existing
  bug, unrelated to the history/dispute logic this feature added, but in a
  file this feature touches. Added `$folderCreator = new FolderCreator();`
  right before first use, matching the exact instantiation pattern already
  used in `confirm_speak.php`/`speech.php`.
- **Noted, not changed** (pre-existing, outside this feature): the
  proposal-tie-break `ORDER BY` silently picking one of several competing
  corrections — predates this session, already tracked as recommendation #7
  in `LOG_EDIT_REVIEW_RECOMMENDATIONS.md`.

`flutter analyze` re-run clean after all fixes; the revert/reject/apply SQL
was re-verified against the live DB with the same disposable test-row method
described above.

## Open recommendation — not yet actioned

- **Add a server-side `levelAccess` check to `resolve_logedit_dispute.php`
  (and arguably `save_logedit_dispute.php`)**: right now these are gated only
  by the static shared app token (`tSecretAPIKey`, embedded in the client
  binary) plus the Flutter client's own UI gating (`show_member.dart` only
  shows the admin screen when `isAdmin`). Anyone who extracts the token can
  POST `action=revert` directly and roll back an already-confirmed
  correction, bypassing the app entirely. This matches the exact same
  pre-existing gap in `confirm_correct.php`/`update_logedit_confirm.php`
  (not introduced by this feature), and was explicitly deferred during
  planning rather than fixed — worth doing as a follow-up if/when the
  broader backend-authz gap across all of these endpoints gets addressed,
  not just for this one.

## Follow-up UI fixes (2026-11-26, user-requested, unrelated to the dispute logic itself)

Two dialogs in `show_logedit_save.dart` (`ShowCorrectSave`, the same screen
this feature added the dispute button to) had a pre-existing sizing issue
the user noticed while reviewing the screen: `_showDialogUser` ("รายชื่อ
สมาชิกที่ยืนยันแล้ว") and `_showDialogUserCorrect` ("รายชื่อสมาชิกที่แจ้ง
คำที่น่าจะผิด/คำที่น่าจะถูก") both used `SizedBox(width: double.maxFinite)`
with `ListView.builder(shrinkWrap: true)` — on wide screens the dialog
looked close to full-screen, and a long reporter list had nowhere to
scroll within a bounded area. Fixed both: width clamped to
`(screenWidth * 0.8).clamp(0, 400)`, height clamped to
`(screenHeight * 0.5).clamp(200, 500)`, `shrinkWrap` removed (the now-bounded
height makes the `ListView` scroll properly instead of trying to grow to
fit every row).

Separately, `_showDialogUserCorrect`'s backing endpoint,
`public_site/workspace/showuserinpagecorrect.php`, only ever selected
`users.*` plus a converted date — no indication of what each person
actually reported. Added `log_edit.tripitaka91_wordincorrect`,
`tripitaka91_wordcorrect`, `tripitaka91_wordcorrectcomment` to its `SELECT`,
and the dialog's `ListTile.subtitle` now shows the word pair and comment
per reporter when present (companion to the same comment-display fix in
`pageviews_html.dart`'s report dialog — see `BOOK_FEATURE_QA_NOTES.md` #7
for the full story of why that comment field matters, discovered via the
`Rotor206` investigation).

`flutter analyze` clean after each. Same deployment caveat: the PHP change
is in `public_site/workspace/`, not live until uploaded.

## Next step

Upload the 4 touched/new `public_site/workspace/*.php` files to the live server, then
do a real end-to-end pass from the running app (apply → dispute → revert
and apply → dispute → reject) with real test accounts, per the verification
checklist in the approved plan.
