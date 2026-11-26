"""
Read-only analysis of the log_edit correction-report backlog.

Connects to the production MySQL/MariaDB (same credentials as
public_site/workspace/db_connect.php, reachable here via the external tunnel port),
joins every log_edit row against the CURRENT book_detail in
tripitaka91_91book_line (matched via book_lines, per
LOG_EDIT_IMPORT_WORKFLOW.md), and buckets every distinct (book, page, line)
into one of:

  auto_apply           - unambiguous single-occurrence match; safe to apply
  manual_fulltext      - a reviewer already typed the full corrected line
                         (book_detail_new); split further by whether the
                         current text still matches what they saw
  conflict             - multiple reporters propose genuinely different text
  ambiguous_occurrence - the reported wrong text occurs more than once on
                         the line, so a blind replace could hit the wrong spot
  no_match             - reported wrong text doesn't appear in current text
                         (even after the known PUA-character fallback)
  noop_or_empty        - wrong == correct, or no wrong text given
  line_not_found       - (book, page, line) doesn't exist in
                         tripitaka91_91book_line at all

This script makes NO changes - read-only queries only. See
LOG_EDIT_BULK_REVIEW.md at the repo root for current counts, decisions
made, and the plan for actually applying the "safe" buckets.
"""

import pymysql
import csv
import json
import os
from collections import defaultdict

conn = pymysql.connect(
    host="45.91.133.62",
    port=33062,
    user="root",
    password="newMySQLtripitaka91",  # same as public_site/workspace/db_connect.php DBpass
    database="tripitaka91_dbnew",
    charset="utf8mb4",
    cursorclass=pymysql.cursors.DictCursor,
)

PUA_FOR_THO = ["", "", ""]  # known PUA codepoints seen standing in for "ฐ"


def try_match(text, word):
    """Return (matched_word, count) using direct match, else PUA substitution fallback."""
    if word in text:
        return word, text.count(word)
    if "ฐ" in word:
        for pua in PUA_FOR_THO:
            variant = word.replace("ฐ", pua)
            if variant in text:
                return variant, text.count(variant)
    return None, 0


print("Fetching log_edit...")
with conn.cursor() as cur:
    cur.execute("""
        SELECT tripitaka91_book AS book, tripitaka91_page AS page, tripitaka91_line AS line,
               tripitaka91_user AS user, book_detail_old, book_detail_new,
               tripitaka91_wordincorrect AS wrong, tripitaka91_wordcorrect AS correct,
               book_confirm, book_suscess, tripitaka91_dateedit AS dateedit
        FROM log_edit
    """)
    rows = cur.fetchall()
print(f"  {len(rows)} rows")

groups = defaultdict(list)
for r in rows:
    groups[(r["book"], r["page"], r["line"])].append(r)

print(f"Fetching current book_detail for {len(groups)} distinct lines...")
current_text = {}
keys = list(groups.keys())
with conn.cursor() as cur:
    batch = 2000
    for i in range(0, len(keys), batch):
        chunk = keys[i:i + batch]
        placeholders = " OR ".join(["(book_id=%s AND book_pages=%s AND book_lines=%s)"] * len(chunk))
        params = [v for k in chunk for v in k]
        cur.execute(
            f"SELECT book_id, book_pages, book_lines, book_detail FROM tripitaka91_91book_line WHERE {placeholders}",
            params,
        )
        for row in cur.fetchall():
            current_text[(row["book_id"], row["book_pages"], row["book_lines"])] = row["book_detail"]
print(f"  found {len(current_text)} matching lines")

conn.close()

buckets = defaultdict(list)

for key, grp in groups.items():
    book, page, line = key
    current = current_text.get(key)
    num_reporters = len(grp)

    if current is None:
        buckets["line_not_found"].append({"book": book, "page": page, "line": line,
                                           "num_reporters": num_reporters})
        continue

    manual_rows = [r for r in grp if r["book_detail_new"]]
    if manual_rows:
        manual_rows.sort(key=lambda r: (r["book_confirm"] or 0, r["dateedit"]), reverse=True)
        chosen = manual_rows[0]
        matches_old = (chosen["book_detail_old"] or "").strip() == (current or "").strip()
        buckets["manual_fulltext"].append({
            "book": book, "page": page, "line": line,
            "reported_old": chosen["book_detail_old"],
            "new_text": chosen["book_detail_new"],
            "current_text": current,
            "matches_old": matches_old,
            "num_reporters": num_reporters,
        })
        continue

    pairs = []
    seen_pairs = set()
    for r in grp:
        w, c = r["wrong"], r["correct"]
        if not w or not c or w == c:
            continue
        if (w, c) in seen_pairs:
            continue
        seen_pairs.add((w, c))
        pairs.append((w, c))

    if not pairs:
        buckets["noop_or_empty"].append({"book": book, "page": page, "line": line,
                                          "num_reporters": num_reporters})
        continue

    results = {}  # resulting text -> list of (matched_word, correct)
    unmatched = []
    ambiguous = []
    for w, c in pairs:
        matched_word, count = try_match(current, w)
        if matched_word is None:
            unmatched.append((w, c))
            continue
        if count > 1:
            ambiguous.append((matched_word, c, count))
            continue
        new_text = current.replace(matched_word, c, 1)
        results.setdefault(new_text, []).append((matched_word, c))

    if len(results) == 1:
        new_text = next(iter(results))
        variants_used = results[new_text]
        buckets["auto_apply"].append({
            "book": book, "page": page, "line": line,
            "old_text": current, "new_text": new_text,
            "variants_used": variants_used,
            "num_reporters": num_reporters,
            "num_distinct_pairs": len(pairs),
        })
    elif len(results) > 1:
        buckets["conflict"].append({
            "book": book, "page": page, "line": line,
            "current_text": current,
            "variants": dict(results),
            "num_reporters": num_reporters,
        })
    elif ambiguous:
        buckets["ambiguous_occurrence"].append({
            "book": book, "page": page, "line": line,
            "current_text": current,
            "ambiguous": ambiguous,
            "unmatched": unmatched,
            "num_reporters": num_reporters,
        })
    else:
        buckets["no_match"].append({
            "book": book, "page": page, "line": line,
            "current_text": current,
            "unmatched": unmatched,
            "num_reporters": num_reporters,
        })

print("\n=== Summary (by distinct line) ===")
total = 0
for name, items in sorted(buckets.items(), key=lambda kv: -len(kv[1])):
    print(f"  {name}: {len(items)}")
    total += len(items)
print(f"  TOTAL distinct lines: {total}  (should equal {len(groups)})")

outdir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "output")
os.makedirs(outdir, exist_ok=True)


def write_csv(name, items, fieldnames, row_fn):
    path = os.path.join(outdir, f"{name}.csv")
    with open(path, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for it in items:
            writer.writerow(row_fn(it))
    print(f"wrote {path} ({len(items)} rows)")


write_csv("auto_apply", buckets["auto_apply"],
          ["book", "page", "line", "num_reporters", "num_distinct_pairs", "old_text", "new_text", "variants_used"],
          lambda it: {**{k: it[k] for k in ["book", "page", "line", "num_reporters", "num_distinct_pairs", "old_text", "new_text"]},
                      "variants_used": json.dumps(it["variants_used"], ensure_ascii=False)})

write_csv("manual_fulltext", buckets["manual_fulltext"],
          ["book", "page", "line", "num_reporters", "matches_old", "reported_old", "current_text", "new_text"],
          lambda it: it)

write_csv("conflict", buckets["conflict"],
          ["book", "page", "line", "num_reporters", "current_text", "variants"],
          lambda it: {**{k: it[k] for k in ["book", "page", "line", "num_reporters", "current_text"]},
                      "variants": json.dumps(it["variants"], ensure_ascii=False)})

write_csv("ambiguous_occurrence", buckets["ambiguous_occurrence"],
          ["book", "page", "line", "num_reporters", "current_text", "ambiguous", "unmatched"],
          lambda it: {**{k: it[k] for k in ["book", "page", "line", "num_reporters", "current_text"]},
                      "ambiguous": json.dumps(it["ambiguous"], ensure_ascii=False),
                      "unmatched": json.dumps(it["unmatched"], ensure_ascii=False)})

write_csv("no_match", buckets["no_match"],
          ["book", "page", "line", "num_reporters", "current_text", "unmatched"],
          lambda it: {**{k: it[k] for k in ["book", "page", "line", "num_reporters", "current_text"]},
                      "unmatched": json.dumps(it["unmatched"], ensure_ascii=False)})

write_csv("line_not_found", buckets["line_not_found"],
          ["book", "page", "line", "num_reporters"], lambda it: it)

write_csv("noop_or_empty", buckets["noop_or_empty"],
          ["book", "page", "line", "num_reporters"], lambda it: it)
