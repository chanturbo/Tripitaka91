# Bulk review: 84,000+ pending `log_edit` correction reports

Status as of 2026-11-26. Picks up from `LOG_EDIT_IMPORT_WORKFLOW.md` and
`LOG_EDIT_REVIEW_RECOMMENDATIONS.md`, but this is a different problem: those
two docs are about manually importing small ad-hoc batches (tens of rows).
This doc is about processing the **existing backlog already sitting in the
production `log_edit` table** — 84,917 rows, submitted over time through the
app's own "แจ้งคำผิดคำถูก" feature, of which **zero have ever actually been
applied** to the book content (`book_suscess` is 0 on every single row).

## How the data was reached

The production DB runs in Docker (`host=database` inside the container, per
`public_site/workspace/db_connect.php`) and isn't reachable directly from a dev machine.
The user exposed it via an external port instead:

- Host: `45.91.133.62`, Port: `33062`
- User: `root`, Database: `tripitaka91_dbnew`
- Password: same as `public_site/workspace/db_connect.php`'s `DBuser`/`DBpass`
  (not repeated here, but it *is* hardcoded in `tools/log_edit_bulk_review/analyze_log_edit.py`,
  consistent with how `db_connect.php` already keeps it in plain text in this repo)
- It's a MariaDB 10.6.20 server, `mysql` CLI and `pymysql` (Python) both work
  against it directly.

## The schema, as actually observed

`log_edit` primary key is **4 columns**: `(tripitaka91_book, tripitaka91_page,
tripitaka91_line, tripitaka91_user)` — confirms recommendation #7 in
`LOG_EDIT_REVIEW_RECOMMENDATIONS.md`. 51,917 distinct (book, page, line)
locations are referenced by the 84,917 rows; 29,187 of those locations have
more than one reporter (up to 6 on a single line).

`book_confirm` / `book_suscess`:
- `book_confirm` is incremented (or hard-set per the known bug) when a second
  member submits full corrected line text via `update_logedit.php`. Only 999
  rows have `book_confirm >= 1`.
- `book_suscess` is set to 1 by `confirm_correct.php` once an admin actually
  applies a fix to `tripitaka91_91book_line.book_detail`. **This is 0 on all
  84,917 rows** — the backlog has never been worked through at all.

## Analysis script

`tools/log_edit_bulk_review/analyze_log_edit.py` (read-only, makes no writes):

1. Pulls every `log_edit` row.
2. Pulls the **current** `book_detail` for every referenced line from
   `tripitaka91_91book_line`, joined on `book_lines` (never `book_line` —
   see `LOG_EDIT_IMPORT_WORKFLOW.md`).
3. Groups rows by `(book, page, line)` and, per group:
   - If any row already has `book_detail_new` (a reviewer-typed full corrected
     line), picks the best one (highest `book_confirm`, most recent edit —
     mirrors `confirm_correct.php`'s own tie-break) → bucket `manual_fulltext`.
   - Otherwise, collects the distinct `(wordincorrect, wordcorrect)` pairs
     reported for that line, and for each tries to find `wordincorrect` as a
     literal substring of the current text (falling back to the known PUA
     code points standing in for `ฐ`, per `LOG_EDIT_IMPORT_WORKFLOW.md`).
   - If every variant that matches ends up producing the **same resulting
     line** → bucket `auto_apply` (safe — doesn't matter which reporter's
     wording you used, they agree on the outcome).
   - If variants produce **different** resulting lines → bucket `conflict`
     (genuine disagreement, needs a human to pick).
   - If the matched word occurs **more than once** on the line → bucket
     `ambiguous_occurrence` (blind replace could hit the wrong occurrence).
   - If nothing matches at all (even with the PUA fallback) → bucket
     `no_match` (likely stale: line already changed since reported, wrong
     line number, or a non-substitution report like an insertion).
   - `wordincorrect == wordcorrect` or empty → `noop_or_empty`.
   - `(book, page, line)` not found in `tripitaka91_91book_line` at all →
     `line_not_found`.

Outputs land in `tools/log_edit_bulk_review/output/*.csv` (git-ignored —
regenerate by rerunning the script; see `.gitignore`).

## Results (run on 2026-11-26)

| Bucket | Distinct lines | Notes |
|---|---:|---|
| `auto_apply` | 43,355 | Unambiguous, single result regardless of which duplicate report is used |
| `manual_fulltext` (current text still matches what the reviewer saw) | 492 | A human already typed the full corrected line |
| `manual_fulltext` (current text has since changed) | 6 | Needs a manual re-check before applying |
| `conflict` | 3,368 | Reporters propose genuinely different corrections (e.g. "ธรรมกา" → "ธรรมีกถา" vs "ธรรมกถา" vs "ธรรมกาย") |
| `no_match` | 3,262 | Reported wrong text not found in current line text |
| `ambiguous_occurrence` | 1,212 | Reported wrong text occurs 2+ times on the line |
| `noop_or_empty` | 190 | Nothing to actually change |
| `line_not_found` | 32 | (book, page, line) doesn't exist |
| **Total distinct lines** | **51,917** | |

**43,847 lines (`auto_apply` + matching `manual_fulltext`) are considered
safe to apply automatically** — about 84% of all distinct reported lines.
The remaining ~8,370 need a human to look at them (the CSVs above are meant
to make that tractable — e.g. `conflict.csv` already lists the candidate
corrections side by side per line).

## Decision so far

Presented this summary to the user on 2026-11-26 and asked whether to go
ahead and apply the 43,847 safe lines to production. **User said: not ready,
wait.** Nothing has been written to production yet — this whole exercise so
far is read-only.

### Confirmation-policy clarification (2026-11-26)

User asked to change their team's confirmation practice from "10 people
must confirm" down to "1 person with permission can confirm", with an
exception that when Claude is the one validating/applying a correction, it
can go through without waiting on a human confirmation count at all.

Checked the actual code: **there is no hard-coded "10 confirmations"
threshold anywhere** — `book_confirm` is only ever used to show an
in-progress status badge (`record['book_confirm'] > 0`, see
`lib/widget/login/show_logcorrect_m.dart:148`), and `confirm_correct.php`
applies a fix as soon as `book_detail_new` is present, with no count check.
So "10 people" was the team's own informal practice, not an enforced rule —
there's no code to change for this policy shift itself.

For the bulk-backlog cleanup in this doc specifically: the 43,847-line
"safe" bucket was never going through the normal reporter→reviewer→admin
relay at all (most of those lines never had a second human type
`book_detail_new`) — the automated direct-text-matching validation
(unambiguous single match, or all duplicate reports agreeing on the same
resulting line) is what stands in for a confirmation here. User's statement
is being read as: that validation is accepted as sufficient, and no
additional per-line human confirmation is required before applying.

**This still does not mean "go apply it now."** Asked the user directly
whether to dry-run or apply for real — **answer was again "ยังไม่พร้อม รอก่อน"
(not ready, wait).** Treat the policy point as settled, but the actual
production write as still pending a separate, explicit go-ahead.

## Plan for when the user says go

For the ~43,847 safe lines:

1. Back up the current `book_detail` for every affected `(book, page, line)`
   before changing anything (a timestamped SQL/CSV snapshot, so this is
   reversible).
2. Apply `new_text` from `auto_apply.csv` / `manual_fulltext.csv` to
   `tripitaka91_91book_line.book_detail` for each line (parameterized, not a
   blind bulk `REPLACE`, since the matching/dedup logic above isn't
   expressible as one plain SQL statement).
3. Set `book_suscess = 1` on **every** `log_edit` row for each applied line
   (not just one user's row) — mirrors what `confirm_correct.php` already
   does for a single-row admin-triggered apply.
4. Do **not** touch `book_confirm` — leave existing recommendation #2 (the
   hard-reset bug in `update_logedit.php`) as a separate, already-documented
   issue.
5. Wrap in a transaction; run once user explicitly confirms, never as a side
   effect of analysis.

The `conflict` / `no_match` / `ambiguous_occurrence` buckets are a separate,
smaller follow-up — likely still needs a person (or a follow-up session) to
go through `tools/log_edit_bulk_review/output/*.csv` and decide case by case.

## Next step

Rerun `tools/log_edit_bulk_review/analyze_log_edit.py` if the backlog has
changed since 2026-11-26 (new reports keep coming in via the app), then ask
the user whether to proceed with step-by-step application of the safe
bucket, or tackle one of the manual-review buckets first.

**2026-11-26, later the same day**: user confirmed they intend to come back
and resume this specific work (the 43,847-line safe-apply backlog) next —
asked Claude to confirm it still remembered the numbers/plan rather than
re-explaining from scratch, then asked to just log this check-in rather
than start immediately. Offered to rerun the analysis script first (per
the note above) before applying anything; user hasn't said go yet. Status
unchanged otherwise: still nothing written to production from this backlog.
