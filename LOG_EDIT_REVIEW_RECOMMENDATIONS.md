# Review notes & recommendations: "แจ้งคำผิดคำถูก" correction pipeline

Working notes from a review session of the full correction-report flow
(`log_edit`, `log_edit_confirm`, `tripitaka91_91book_line`) — what was found,
what was already fixed, and what's still open for a decision. Companion to
`LOG_EDIT_IMPORT_WORKFLOW.md` (how to prepare import SQL) — this file is about
the PHP workflow itself and data-quality issues in the content tables.

## Already fixed this session

- **`public_site/workspace/confirm_correct.php`**: guarded against applying a NULL/empty
  `book_detail_new` onto the live `book_detail` (would have blanked out real
  scripture text). Also made the row-selection deterministic
  (`ORDER BY book_detail_new IS NOT NULL DESC, tripitaka91_dateedit DESC LIMIT 1`)
  instead of relying on MySQL's undefined row order when multiple rows exist
  for the same (book, page, line). **Still needs to be uploaded to the live
  server — this repo's `public_site/workspace/` is a local staging copy, not auto-deployed.**
- **Data fix (already applied directly to production `tripitaka91_91book_line.book_detail`)**:
  535 lines had the Thai vowel ำ stored as the decomposed sequence
  NIKHAHIT+SARA-AA (`ํา`) instead of the single precomposed
  character (`ำ`) — normalized via `REPLACE`. Backup of the affected
  rows' original text was saved (session scratchpad, not in the repo).
- **Recommendation #3 (no audit trail) — done, 2026-11-26**: added two new
  tables directly to production, `log_edit_history` (every apply now
  snapshots `book_detail` before/after, who applied it, and whether it's
  since been reverted) and `log_edit_dispute` (members can flag an applied
  fix as wrong; an admin reviews and reverts or rejects). `confirm_correct.php`
  now writes a `log_edit_history` row before its overwrite. Three new PHP
  endpoints: `save_logedit_dispute.php`, `show_logedit_dispute_withall.php`,
  `resolve_logedit_dispute.php`. New Flutter admin screen
  `lib/widget/login/show_logedit_dispute.dart` (`LogEditDisputePage`), wired
  into `show_member.dart`'s admin-tools block. **Same caveat as the
  `confirm_correct.php` fix above: the new/changed `public_site/workspace/*.php` files
  are local only — not yet uploaded to the live server.** Full design and
  verification steps: see `LOG_EDIT_DISPUTE_FEATURE.md` at the repo root.
- Also bundled into the same work: `tCorrectNum` (`lib/utils/constants/api_constants.dart`)
  changed from `10` to `1` — the "ยืนยันการแก้ไขข้อมูล" apply button now
  appears after a single member confirmation instead of ten, per the user's
  decision to relax that threshold.

## Open recommendations — safe / non-structural

1. **Add an index** on `tripitaka91_91book_line (book_id, book_pages, book_lines)`.
   Currently the only index is the PK on `(book_id, book_pages, book_line)` —
   `book_lines` (the real citation-stable line number everything should query
   by, per `LOG_EDIT_IMPORT_WORKFLOW.md`) is unindexed. Not causing a visible
   slowdown today because every current query already narrows by
   `book_id`+`book_pages` via the PK first — this is precautionary, not a bug
   fix.
2. **Fix `update_logedit.php`**: it does `SET book_confirm = 1` (a hard reset)
   instead of leaving the existing confirm count alone, every time someone
   submits a "ข้อความที่น่าจะถูก". This silently wipes out previously
   accumulated confirmations.
3. **No audit trail for who applied a fix**: `confirm_correct.php` doesn't
   take or record which admin account triggered it. Worth adding a
   `confirmed_by`/`confirmed_at` (or a small audit table) given this
   permanently overwrites scriptural text.
4. **Validate at submission time** (`save_logedit.php`): reject when
   `wordincorrect == wordcorrect` (no-op report), and reject when
   `wordincorrect` isn't actually a substring of the submitted
   `book_detail_old` — would have caught the `book_line` vs `book_lines`
   line-number mixup automatically instead of needing manual review.
5. **Normalize to Unicode NFC on write** — in `save_logedit.php` and
   wherever `book_detail`/`book_detail_new` get written — to stop the
   decomposed-vowel issue (and similar) from recurring.
6. **Turn the manual data-quality queries from this session into a recurring
   script** (leftover PUA chars ``/``/``, decomposed Thai
   vowels) instead of relying on someone noticing by eye.

## Open — structural, needs discussion before changing

7. **PK is 4 columns `(book, page, line, user)` but the confirm/apply logic
   only keys on 3** (`book, page, line`). Multiple users can and do have
   independent rows at the same line; `show_logedit_withall.php` already
   merges them for display via `GROUP_CONCAT`/`MAX`, but `confirm_correct.php`
   can only apply one. The deterministic `ORDER BY` fix above papers over
   this but doesn't resolve it — would need an actual design decision (e.g.
   one canonical proposal per line, chosen explicitly, instead of merging
   free text from multiple reporters).
8. **`log_edit_confirm` has no UNIQUE constraint** (as far as checked) to stop
   the same user confirming the same line more than once, which would inflate
   `book_confirm` beyond the real distinct-confirmer count. Worth confirming
   and adding `UNIQUE (tripitaka91_book, tripitaka91_page, tripitaka91_line, tripitaka91_user)`
   if missing.

## Next step

Waiting on which of the above (1–6 first, pending any 7/8 design discussion)
to actually implement.
