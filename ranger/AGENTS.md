# Ranger Agent Runbook

This repo is a ranger config deployed at `~/.config/ranger`.

## Files That Matter

- `rc.conf`: keymaps and ranger settings.
- `scope.sh`: preview pipeline for text and image previews.
- `commands.py`: top-level custom command imports.
- `plugins/kitty_icat_preview.py`: kitty image preview backend.
- `plugins/ranger_dragon.py`: `:dragon` command.
- `scripts/sxiv-current-dir`: open images in current directory with `sxiv`.
- `scripts/sxiv-fzf`: pick an image with `fzf`, then open it with `sxiv`.

## Exact Change Points

### Add or change a keybinding

Edit `rc.conf`.

Examples:

- `map yd dragon`
- `map iv shell -f ~/.config/ranger/scripts/sxiv-current-dir %f`
- `map gd cd ~/Downloads`

Rules:

- Use `map`.
- If the binding calls a script, use the deployed path under `~/.config/ranger/...`.
- If the binding calls a ranger command, add that command in Python first.

### Add or change a preview

Edit `scope.sh`.

Actual execution order:

1. `MIMETYPE="$( file --dereference --brief --mime-type -- "${FILE_PATH}" )"`
2. If `PV_IMAGE_ENABLED=True`, `handle_image "${MIMETYPE}"`
3. `handle_extension`
4. `handle_mime "${MIMETYPE}"`
5. `handle_fallback`

Use:

- `handle_image` when the preview should render an image and return `6` or `7`.
- `handle_extension` when handling depends on file extension.
- `handle_mime` when handling depends on MIME type.
- Put special image conversions before the generic `image/*)` branch, otherwise ranger will fall through to direct display.

Exit codes used here:

- `1`: this branch failed; continue.
- `5`: show text output.
- `6`: show `$IMAGE_CACHE_PATH` as image.
- `7`: show the source file directly as image.

Example: PDF image preview belongs in `handle_image`, not `handle_extension`, because image handlers run first.

### Add a custom command

Small command:

- Add/import it via `commands.py`.

Standalone feature:

- Put it in `plugins/*.py`.

Rules:

- Use `self.fm.notify(..., bad=True)` for user-facing failures.
- Handle empty selection/current file explicitly.
- Resolve external binaries with `shutil.which()`.
- `commands.py` currently overrides ranger's built-in `:yank` so Wayland prefers `wl-copy` over `xclip`.

### Add a helper script

Put it in `scripts/`.

Rules:

- Use `#!/usr/bin/env bash`
- Use `set -euo pipefail`
- Keep it runnable outside ranger

## Current External Dependencies

Required by current config:

- `trash-put`: used by ranger's built-in `:trash` command, now bound to `dD`.
- `wl-copy`: preferred clipboard backend on Wayland for `yank` bindings like `yp`, `yd`, `yn`, `yb`.
- `kitten`: for kitty image previews.
- `poppler`: provides `pdftoppm` and `pdftotext` for PDF preview.
- `magick` or `convert`: used to normalize SVG and image formats that should render through the preview cache.
- `sxiv`: for `scripts/sxiv-current-dir`.
- `fzf`: for `scripts/sxiv-fzf`.
- `file`: used by `scope.sh` and `scripts/sxiv-fzf`.
- `identify`: used by `scripts/sxiv-fzf` preview; usually from ImageMagick.

Referenced but not vendored in this repo:

- `plugins.ranger_udisk_menu.mounter` imported by `commands.py`

Optional runtime helpers:

- `xdragon`, `dragon-drop`, or `dragon`: used by `:dragon`

## Precise Debug Flow

### Keybinding issue

Check `rc.conf`.

Questions:

- Does the mapping exist?
- Does it call the correct deployed path?
- Does the target command/script exist?

### Preview issue

Check `scope.sh`.

Run:

```bash
bash scope.sh /path/to/file 80 40 /tmp/ranger-preview.jpg True
echo $?
```

Then verify:

```bash
file --dereference --brief --mime-type -- /path/to/file
bash -n scope.sh
command -v kitten
command -v magick
command -v convert
command -v rsvg-convert
command -v pdftoppm
command -v pdftotext
```

Interpretation:

- `6`: image preview path worked.
- `5`: text preview path worked.
- `1`: this handler failed; ranger falls through.

If no image appears:

- Confirm `set preview_images true` in `rc.conf`
- Confirm `set preview_images_method kitty`
- Confirm `kitten` is in `PATH`
- Confirm the relevant handler writes the cache file

### Python command/plugin issue

Run:

```bash
python -m py_compile commands.py plugins/*.py
```

Then check:

- missing import in `commands.py`
- missing binary expected by plugin code
- wrong deployment path under `~/.config/ranger`

### Shell helper script issue

Run directly:

```bash
scripts/sxiv-current-dir .
scripts/sxiv-fzf .
```

If it fails, debug the script first, not ranger.

## Issue Tracking Format

Use this exact structure when you investigate or fix a ranger problem.

### Issue

One sentence stating the user-visible failure.

Example:

`PDF files show text metadata/text extraction instead of a rendered page preview in ranger.`

### Impact

One sentence stating what is broken and where.

Example:

`With kitty image previews enabled, PDFs do not render as images in the preview pane.`

### Root Cause

State the precise failing condition.

Example:

`scope.sh had the PDF renderer in handle_image commented out, so application/pdf never returned exit 6 and ranger fell through to text-based PDF handlers.`

### Fix

State the exact code change.

Example:

`Uncommented the application/pdf block in handle_image so scope.sh now runs pdftoppm on the first page and writes the result to $IMAGE_CACHE_PATH.`

### Why This Works

State the execution-path reason, not just the symptom.

Example:

`handle_image runs before handle_extension and handle_mime. Returning exit 6 for application/pdf makes ranger use the generated preview image immediately, so the later text fallback is no longer selected when pdftoppm succeeds.`

### Verification

List the exact checks run.

Example:

- `bash -n scope.sh`
- `command -v pdftoppm`
- open a PDF in ranger with image previews enabled

## Change Rules

- Make the smallest change that fixes the issue.
- Do not add a second preview path when `scope.sh` already has the correct extension point.
- Do not convert deployed absolute paths in `rc.conf` to repo-relative paths unless deployment is also being changed.
- Do not remove imports for external plugins unless you verified they are truly unused in the live config.
