# public_site/

The front-page PHP website (`https://www.tripitaka91.com/`), moved here from
`D:\WebTripitaka91\tripitaka91-site\ไฟล์ PHP index\` on 2026-11-26 so the
code is version-controlled, same as `workspace/` (the API backend) already
is for this project.

## What's tracked here

All the actual code/small assets: `*.php`, `.htaccess`, `contact_us.html`,
`favicon.png`, `privacy/`, `img/`, `icons/`,
`สำรองเปลี่ยนรูปแบบการแสดง/` (an earlier manual backup of
`tri91_process.php` the user had already made, carried over as-is).

## What's deliberately NOT tracked (see `.gitignore`)

The original folder was 363MB total, almost all of it static content that
doesn't belong in git history:

- `pdf/` (270MB) — the actual scripture PDFs served by the site.
- `tri91_old/` (65MB) — a legacy backup folder.
- `assets/` (27MB) — looks like an old Flutter-web build's output
  (`AssetManifest.bin.json`, `web_support.js`, fonts, images matching this
  app's own asset structure) — generated build output, not source, same
  reasoning as why `build/` is gitignored for the Flutter app itself.

These three were **not copied** into this repo at all — they still live
only at the original `D:\WebTripitaka91\tripitaka91-site\ไฟล์ PHP index\`
location. If the live server needs them, they have to be deployed/kept in
sync separately from git (e.g. direct upload/rsync), not through this repo.
The `.gitignore` rules exist so that if someone copies them into
`public_site/` locally out of habit, they won't get committed by accident.

## Deployment

Like `workspace/`, this is a local staging copy — editing files here does
**not** change the live site. Upload changes to the server yourself.
