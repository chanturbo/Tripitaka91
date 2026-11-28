# public_site/

The front-page PHP website (`https://www.tripitaka91.com/`), moved here from
`D:\WebTripitaka91\tripitaka91-site\ไฟล์ PHP index\` on 2026-11-26 so the
code is version-controlled.

`workspace/` (the API backend — also called over HTTP by the Flutter app
itself, not just this website) lives nested inside here as
`public_site/workspace/`, matching the real deployed layout: on the live
server, `workspace/` already sits as a direct subfolder of wherever
`tripitaka91.php` lives, since every page's `include('workspace/db_connect.php')`
only resolves that way. Nesting it here in the repo mirrors that exactly —
it does **not** change the live URL (`https://www.tripitaka91.com/workspace/...`
stays the same either way).

## What's tracked here

All the actual code/small assets: `*.php`, `.htaccess`, `contact_us.html`,
`favicon.png`, `privacy/`, `img/`, `icons/`,
`สำรองเปลี่ยนรูปแบบการแสดง/` (an earlier manual backup of
`tri91_process.php` the user had already made, carried over as-is), and
**`tri91_legacy/include_file/`** (minus the 3 files below) — small PHP files
(`webconfig.php`, `function.php`, etc.) that `tripitaka91.php`/`tripitaka91_1.php`
actually `include()`. Don't assume `tri91_legacy/` is dead legacy code — only
the parts outside `include_file/` are purely static vendor assets (see
below).

**Deliberately excluded from `include_file/`, never commit these**:
`dbconnect.php`, `dbconnect1.php`, `dbconnect_odbc.php` — confirmed unused
dead code (only referenced by other unused legacy files inside `tri91_legacy/`
itself), and they embed a MySQL password. Kept on disk, gitignored.

## What's on disk but NOT tracked (see `.gitignore`)

`tri91_legacy/` (minus `include_file/`), `pdf/`, and `assets/` are copied onto
disk here (so local references/paths resolve and a full working copy of the
site exists in one place) but are **gitignored**, not committed:

- `tri91_legacy/css|js|img|fonts|datatables*|jBox-master|font-awesome|multiselect/`
  — vendored third-party front-end libraries (Bootstrap, jQuery, DataTables,
  jBox, Font Awesome) that `tripitaka91.php`/`tripitaka91_1.php` reference
  by relative path. Load-bearing for those two pages to render, but static
  and rarely-changing, so not worth git history (~13.7MB).
- `pdf/` (270MB) — the actual scripture PDFs served by the site. **Not
  copied onto disk here at all** — still only at the original
  `D:\WebTripitaka91\tripitaka91-site\ไฟล์ PHP index\pdf\`.
- `assets/` (27MB) — looks like an old Flutter-web build's output
  (`AssetManifest.bin.json`, `web_support.js`, fonts, images matching this
  app's own asset structure) — generated build output, not source, same
  reasoning as why `build/` is gitignored for the Flutter app itself. Also
  **not copied onto disk here**.

If the live server needs `pdf/`/`assets/`, they have to be deployed/kept in
sync separately from git (direct upload/rsync), not through this repo.

Also gitignored: `workspace/db_connect.php`, `workspace/db_correction.php`,
`workspace/websiteconfig.php` (real secrets — DB password, speech API keys,
the shared app token) and `workspace/sounds/` (runtime-generated TTS audio
cache). These were already untracked by this project's own established
convention even before this move — this just makes it explicit.

## Deployment

This is a local staging copy — editing files here does **not** change the
live site. Upload changes to the server yourself.
