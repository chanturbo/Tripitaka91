# Workflow: Bulk-importing "แจ้งคำผิดคำถูก" reports into `log_edit`

This documents the process used to turn a source of candidate typo corrections
(an Excel sheet or a free-text chat log) into SQL that records them as
correction reports in the production `log_edit` table — the same table the
app's own "แจ้งคำผิดคำถูก" / "ยืนยันการแก้ไขคำผิดคำถูก" screens read and write
(see `CLAUDE.md` and `lib/widget/login/show_logcorrect_m.dart`,
`show_logedit_save.dart`).

## Always prepare SQL first, run only after explicit confirmation

Never execute an INSERT/UPDATE/DELETE against the production database as a
side effect of "preparing" something. Generate the `.sql` file, show the
person what it will do (row count, any assumptions), and only run it after
they explicitly say to.

## `log_edit` schema essentials

Required columns (see `public_site/workspace/save_logedit.php`):

```
tripitaka91_book, tripitaka91_page, tripitaka91_line, book_detail_old,
tripitaka91_wordincorrect, tripitaka91_wordcorrect, tripitaka91_wordcorrectcomment,
tripitaka91_wordsum, tripitaka91_user, tripitaka91_dateadd, tripitaka91_dateadd1,
tripitaka91_dateedit, tripitaka91_dateedit1, tripitaka91_ip
```

- Unique key is **(tripitaka91_book, tripitaka91_page, tripitaka91_line)** —
  only one pending correction per line, regardless of reporter. Use
  `INSERT ... ON DUPLICATE KEY UPDATE` (mirrors the app's own behavior), but
  be aware this **overwrites** any existing pending report at that line.
- `tripitaka91_wordsum` = `1` per the app's own convention.
- `tripitaka91_dateadd`/`tripitaka91_dateedit` = `NOW()`; the `...1` variants
  are date-only = `CURDATE()`.
- `tripitaka91_ip` can be left as an empty string for manually-prepared imports.
- Wrap the whole batch in `START TRANSACTION; ... COMMIT;`, batched ~200 rows
  per `INSERT` statement for very large sets.

## CRITICAL: matching a line number to real content

The book content table is `tripitaka91_91book_line`
(`book_id`, `book_pages`, `book_line`, `book_lines`, `book_detail`, ...).

**Always match against `book_lines` (with an s) — never `book_line`.**
`book_line` is just the physical row's position within the page and includes
placeholder `"LineNull"` rows that don't count as real lines, so it drifts out
of sync with the actual printed/cited line number on pages that contain any
such filler row. `book_lines` is the real, citation-stable line number — it's
what every URL on the site (`.../{book}-{page}-{line}.htm`) and what
`confirm_correct.php`'s own `UPDATE ... WHERE book_lines = :bookline` refer to.

```sql
SELECT book_detail FROM tripitaka91_91book_line
WHERE book_id=%s AND book_pages=%s AND book_lines=%s
```

Before trusting a reported line number, verify the reported "wrong" text
actually appears (see next section) in the line fetched this way. If it
doesn't, search the whole page (`book_id`+`book_pages`, all `book_lines`) for
a line whose text contains it, rather than guessing.

## CRITICAL: legacy private-use-area (PUA) characters

Some older digitized text has certain Pali diacritics (commonly "ฐ") stored
as private-use Unicode code points (seen so far: ``, ``, ``)
left over from a legacy font mapping, instead of the real character. These
render as invisible/missing glyphs in a normal terminal or editor.

When the reported "wrong" word doesn't literally appear as a substring of the
line's `book_detail`, don't assume the location is wrong — first retry the
match with "ฐ" (or other suspect characters) substituted for the likely PUA
code point. `tripitaka91_wordincorrect` (and `book_detail_old`) must use the
**exact literal substring as currently stored**, PUA characters included,
or the app's own substring-based highlighting won't find a match.
`tripitaka91_wordcorrect` should hold the real intended correct text.

## Multiple wrong words on the same line

Because the unique key is per-line, a line with more than one distinct
correction can't get two separate rows. Combine them into one row with
`tripitaka91_wordincorrect`/`tripitaka91_wordcorrect` comma-joined, matching
the convention the app already uses for highlighting multiple terms
(`wordincorrect.split(',')` in `show_logcorrect_m.dart`).

## Validate every row against the live line before finalizing

For every candidate row:
1. Fetch `book_detail` via `book_lines` as above.
2. Confirm the "wrong" text is a literal (whitespace-normalized) substring.
   If not, retry with the PUA substitution, then fall back to a whole-page
   search.
3. Only once resolved, extract the **exact original substring** (preserving
   real spacing and any PUA characters) to use as `tripitaka91_wordincorrect`
   — don't just reuse the source's/human's typed text verbatim.

Report any row that still can't be resolved, or that reduces to
wrong == correct (no actual change), back to the person instead of guessing.

## Sources seen so far, and their quirks

- **Excel sheet with explicit เล่ม/หน้า/บรรทัด columns**: usually paired with
  a companion sheet that also has the full line text (`book_detail`) by the
  same row order — cross-reference instead of re-fetching from the DB if
  the file already has it, but the DB is still the source of truth for
  validation.
- **Free-text chat log** (e.g. a person pasting "`wrong` ควรเป็น `correct`"
  plus a `https://www.tripitaka91.com/{book}-{page}-{line}.htm` link per
  entry): parse the common connector phrases (ควรเป็น / น่าจะเป็น /
  ควรเปลี่ยนเป็น / คิดว่าเป็น / อาจเป็น), but expect a meaningful fraction to
  not fit the pattern (deletions, missing-word insertions, reversed phrasing,
  no original text given, merged/ambiguous blocks) — surface these to the
  person rather than silently guessing.
- **Before importing a chat log**: check whether the same reporter already
  has these exact entries in `log_edit` from using the app's own report
  feature directly — a chat log is sometimes just a parallel/informal copy
  of reports already submitted properly, making the import redundant.

## Attribution

`tripitaka91_user` should be whoever actually reported the correction. If a
registered account exists for that person, use it (`SELECT username FROM
users WHERE ...`) rather than attributing it to whoever is doing the data
entry.
