# Pattern: matching the website's book-detail display to the app

This documents how `public_site/tri91_process_test.php` (loaded via AJAX
into `public_site/tripitaka.php`) was made to render book detail text the
same way the Flutter app does in `lib/features/book/pageviews_html.dart`,
plus a few related UX fixes made to `tripitaka.php` along the way. Apply the
same approach for any future tweak in this area, rather than reinventing
it — the core styling approach was arrived at twice independently (once in
an earlier session on `tri91_old` references, once again in the session
that produced this file) and confirmed both times.

## Style with inline `style=""`, not a wrapper div + CSS class

An earlier attempt wrapped the whole AJAX response in a `<div
class="tri91-line-frame">` and added a scoped `<style>` block to
`tripitaka.php` targeting `.tri91-line-frame .tri-font-detail` etc. This was
reverted in favor of inline `style="..."` attributes written directly into
each `echo` in `tri91_process_test.php`.

Why: it keeps every styling decision local to the one PHP file that renders
it, with no dependency on `tri91_old/css/tri-font.css` (shared with the real
production pages — editing it risks visually changing pages this test file
has nothing to do with) and no wrapper element that has to survive future
edits untouched.

Exception: `tripitaka.php` itself (the outer page shell, not the AJAX
fragment) is rendered server-side on a plain HTTP GET, before any client-side
JS has run — so unlike `tri91_process_test.php`, it has no `$screen` value
available yet to branch on. For shell-level responsive tweaks (see "Mobile
nav-button stacking" below), a scoped `<style>` + `@media` query in
`tripitaka.php`'s `<head>` is the right tool, not a contradiction of the
rule above.

## Reuse `$screen`, don't add a CSS media query (inside the AJAX fragment)

`tri91_process_test.php` already receives `$screen` from the page's own JS
(`window.innerWidth <= 650 ? 1 : 0`), which is a close match for the app's
`isSmallScreen` check (`MediaQuery.of(context).size.width < 600`). Drive all
responsive behavior inside this file from `$screen` server-side instead of
adding `@media` rules.

Per-category header indent (Vinaya/Abhidhamma pitaka get 10 characters of
indent, Suttanta pitaka gets 8, everything else 0 — converted to pixels
with `chars * 24 * 0.25`, the same formula as the app's desktop font size)
is forced to 0 on mobile, matching the app's `headerIndent = isSmallScreen ?
0 : ...`:

```php
$header_indent_chars = ($screen == 1) ? 0 : ($is_vinaya_or_abhidhamma ? 10 : ($is_suttanta ? 8 : 0));
$header_indent_px = $header_indent_chars * 24 * 0.25;
```

## Centering the detail text: shrink-to-fit box, not `text-align:center`

Goal (user request): the left/right margins around the detail text block
should be equal — same distance from the container edge to the first
character as to the last character.

`text-align:center` was tried first and rejected: it centers each line
*individually*, which looks uneven across lines of different lengths, and
it was also rejected as a substitute for equal margins around the whole
block. A fixed `max-width:700px` box was tried next and also rejected,
because a hardcoded pixel width doesn't adapt to the viewport.

The approach that stuck, applied on wide screens (`$screen == 0`) only:

```php
echo "<div class=\"tri-font-detail\" style=\"color:#475859;...;display:table;margin:0 auto;max-width:100%;text-align:left;\">$book_detail<br></div>";
```

`display:table` makes the box shrink-to-fit its widest line (like
`width:fit-content`, but with old-browser support); `margin:0 auto` centers
that shrunk box; `max-width:100%` stops it overflowing a narrow container.
Text inside stays naturally left-aligned — only the block itself is
centered, so individual lines don't jump around relative to each other.

On narrow screens (`$screen == 1`), this whole approach is skipped in favor
of plain `text-align:center` (see "Mobile falls back to plain centering"
below) — there's no room for side gutters on a phone screen anyway.

## Pencil icon / line-number gutters: `position:absolute`, not `float`

The per-line correction icon (`.showCorrect`, Bootstrap `pull-left`) and the
line-number badge (`.hide-line`, Bootstrap `pull-right`) used to float inside
whatever container held the line's text. Once that container became the
shrink-to-fit `display:table` box above, the floats started hugging the
*text's* edges instead of the true left/right edges of the page — because
the box is only as wide as its content, not the full available width.

Fix: swap `pull-left`/`pull-right` (which only worked by relying on a
full-width floated container) for inline `position:absolute;left:0;` /
`position:absolute;right:0;`, and wrap each page's whole output in one
outer, full-width `position:relative` container:

```php
echo "<div style=\"position:relative;padding:0 36px;\"><div class=\"tri-font-detail\" style=\"...display:table;margin:0 auto;max-width:100%;...\">$book_detail<br></div></div>";
```

Why this works without per-line markup: a `position:absolute` element with
only `left`/`right` set (no `top`/`bottom`) keeps its *natural, static*
vertical position — i.e. it still lines up with whatever line it was
emitted next to in the source — while its horizontal position is pinned to
the nearest *positioned* ancestor, which the lookup finds by walking up past
the inner `display:table` div (it has no `position` set) to the outer
`position:relative` wrapper. The outer wrapper's `padding:0 36px` reserves
room on both sides so the gutters don't visually collide with the centered
text box.

Because `position:absolute` (unlike `float`) removes the element from the
block formatting context entirely, it can't intrude on or distort the
shrink-to-fit box's own width calculation — which `float` inside the same
box would have done.

### Mobile falls back to plain centering, no gutters

On narrow screens (`$screen == 1`), skip the whole gutter/shrink-wrap
mechanism — no room for side gutters on a phone. Compute two tiny style
fragments once and splice them into every pencil-icon/line-number span
instead of hardcoding `position:absolute;...` everywhere:

```php
$gutter_left_style  = ($screen == 1) ? '' : 'position:absolute;left:0;';
$gutter_right_style = ($screen == 1) ? '' : 'position:absolute;right:0;';
```

and the final per-page wrapper itself branches the same way: plain
`text-align:center` (no `position:relative`, no padding, no `display:table`)
on mobile; the full gutter+shrink-wrap structure on wide screens.

## Paragraph/indent spacing: HTML collapses repeated spaces, Flutter doesn't

`book_detail` rows use runs of 3-8 literal spaces to mark paragraph
indentation. Flutter's `Text`/`TextSpan` renders those as-is; a browser
collapses any run of whitespace down to a single space by default, so on
the website those indents were silently disappearing.

Fix: convert any run of 2+ consecutive spaces to the same number of
`&nbsp;` characters (leaving single word-separating spaces untouched, so
normal line-wrapping still happens between words). On narrow screens,
collapse the run to exactly 2 `&nbsp;` first — mirroring the app's own
`snapText.replaceAll(RegExp(r' {2,}'), '  ')` under `isSmallScreen`, since a
3-8-space indent is disproportionately wide on a narrow, proportional-font
screen.

```php
function tri91PreserveIndentSpacing($text, $screen) {
    return preg_replace_callback('/ {2,}/', function ($m) use ($screen) {
        $len = ($screen == 1) ? 2 : strlen($m[0]);
        return str_repeat('&nbsp;', $len);
    }, (string) $text);
}
```

## Tag-cleaning helpers ported from the app, not reinvented

`tri91IsHeaderTaggedLine()`, `tri91CleanLegacyTags()`, and
`tri91RenderFootnotes()` in `tri91_process_test.php` are direct ports of
`_isHeaderTaggedLine()`, the big tag-stripping `replaceAll` chain, and the
`supNNNsup` → `<sup>N</sup>` footnote conversion from `showPage()` in
`pageviews_html.dart`. The exact replacement list and order matter — it was
built against real garbled legacy data in the `book_detail` column, not
guessed — so when porting more of the app's text-cleaning logic, copy it
faithfully rather than approximating it.

They also cast inputs with `(string)` before passing them into
`preg_match_all()` / `strtoupper()` / `preg_replace()`, since PHP 8.1+
deprecates passing `null` into those (non-nullable) parameters and a NULL
`book_detail` should never leak a warning into the AJAX response.

## Font size and line spacing: matched in both directions

App defaults (`_loadFontSize()`): 26px on mobile, 24px on desktop/tablet.
After comparing screenshots of the same page side by side, font *size*
wasn't the issue (both were already 26px at the time) — the app's line
spacing just looked more open. The website's `.tri-font-detail` had no
`line-height` set at all (browser default, fairly tight for this font).

Rather than only tweaking the website, `line-height` was added on *both*
sides to bring them in line with each other:

- Website (`tri91_process_test.php`): every inline style that sets
  `font-size:{$detail_font_size}px` also sets `line-height:1.35;` right
  next to it (search for `font-size:{$detail_font_size}px;line-height:` to
  find all the spots — currently 4).
- App (`lib/features/book/pageviews_html.dart`, `baseStyle` inside
  `showPage()`): added `height: 1.35` to match. Flutter's default (no
  `height` set) uses the font's own metrics, which for THSarabunNew render
  visibly more open than a browser's default line-height for the same font.

`$detail_font_size` itself went through several back-and-forth values
during tuning (26 everywhere → 26 mobile/24 desktop → 26 everywhere) — if
asked to change it again, just edit the one `$detail_font_size = ...;` line
near the top of `tri91_process_test.php`; don't reintroduce a second
definition elsewhere (it's read in both the intro/page-0 branch and the
main per-page branch).

## Line numbers hidden by default on load

`tripitaka.php` ships a small `<style>.hide-line{display:none;}</style>` in
the `<head>`, and the page's own script sets `hide_line = true;` on load
(instead of `false`) so the existing "ซ่อน/แสดง หมายเลขบรรทัด" toggle button
shows them correctly on its *first* click rather than trying to hide an
already-hidden state. Don't change one without the other — the CSS default
and the JS boolean have to agree on what "hidden" means.

## Mobile nav-button stacking

The "แสดงรายละเอียดในโหมดเว็บแอพ" and "แสดงเพิ่มเติม" buttons used
`pull-left`/`pull-right` and, on a narrow phone width, their long Thai label
text wrapping to two lines left an ugly, uneven gap between them. Fixed
with a `<div class="tri-nav-buttons">` wrapper and a `@media (max-width:
649px)` block in `tripitaka.php`'s `<head>` that cancels the float
(`float:none`), stacks them in a flex column with a fixed `8px` gap, and
makes each button full width. Desktop/tablet is untouched — the
`pull-left`/`pull-right` spans are still there, just overridden only under
650px. (This is the shell-level exception to "no media queries" above.)

## jBox tooltip was duplicated by the browser's own native tooltip

The `.showCorrect` pencil-icon span carries a `title="..."` attribute (raw
HTML content) that a custom jBox tooltip reads and renders nicely on
hover — but the *browser* also renders its own native tooltip from that
same `title` attribute, as plain unescaped text, stacked on top of the jBox
one. Fixed in `tripitaka.php`'s mouseenter handler: on first hover, the
`title` value is copied into a `data-tip` attribute and the real `title`
attribute is removed, so the browser has nothing left to show a native
tooltip from; jBox keeps reading from `data-tip` on every hover after that.

## Before adding something new here

Check whether `$screen` can drive it with a plain inline style first (for
anything inside `tri91_process_test.php`). That is the established approach
for this file, not a one-off choice. For `tripitaka.php` itself, a scoped
`<style>`/`@media` block is fine since that page has no `$screen` to branch
on at render time.
