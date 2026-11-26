# public_site/

The front-page PHP website (`https://www.tripitaka91.com/`), moved here from
`D:\WebTripitaka91\tripitaka91-site\ไฟล์ PHP index\` on 2026-11-26 so the
code is version-controlled, same as `workspace/` (the API backend) already
is for this project.

## What's tracked here

All the actual code/small assets: `*.php`, `.htaccess`, `contact_us.html`,
`favicon.png`, `privacy/`, `img/`, `icons/`,
`สำรองเปลี่ยนรูปแบบการแสดง/` (an earlier manual backup of
`tri91_process.php` the user had already made, carried over as-is), and
**`tri91_old/include_file/`** — 11 small PHP files (`webconfig.php`,
`dbconnect*.php`, etc.) that `tripitaka91.php`/`tripitaka91_1.php` actually
`include()`. Don't assume `tri91_old/` is dead legacy code — only the parts
outside `include_file/` are purely static vendor assets (see below).

## What's on disk but NOT tracked (see `.gitignore`)

`tri91_old/` (minus `include_file/`), `pdf/`, and `assets/` are copied onto
disk here (so local references/paths resolve and a full working copy of the
site exists in one place) but are **gitignored**, not committed:

- `tri91_old/css|js|img|fonts|datatables*|jBox-master|font-awesome|multiselect/`
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

## Deployment

Like `workspace/`, this is a local staging copy — editing files here does
**not** change the live site. Upload changes to the server yourself.
