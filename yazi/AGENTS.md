# Yazi Agent Runbook

Yazi (terminal file manager, Rust) config for user `shri`. This directory lives at
`~/dotfiles/yazi` and is **out-of-store symlinked** to `~/.config/yazi` by the NixOS
home-manager flake — see `~/dotfiles/nix-config/modules/home-manager/links.nix`
(`configApps` list contains `"yazi"`). Edits here are live and writable; no rebuild is
needed to pick up config changes, only to (re)create the symlink itself.

## Files That Matter

- `yazi.toml`: main config. Sections in use:
  - `[mgr]` — layout (`ratio`), sorting (`natural`, dirs first), `linemode = "size"`,
    `show_hidden = false`, scrolloff, mouse events, title format.
    NOTE: this Yazi build uses `[mgr]`, **not** the legacy `[manager]`.
  - `[preview]` — image preview tuning (filter, quality, sixel/ueberzug).
  - `[opener]` — named opener programs: `edit` (`$EDITOR`, blocking), `open` (`xdg-open`),
    `reveal` (`xdg-open` of the parent dir), `extract` (`7z x`).
  - `[open]` — `rules` mapping mime/url globs to ordered opener lists. **First opener in
    the list is the default action.** xdg-open (`open`) is intentionally first for files so
    Yazi honors XDG defaults instead of forcing `$EDITOR`.
  - `[plugin]`, `[tasks]`, `[input]` — fetchers/previewers prepend lists, worker counts.
- `keymap.toml`: custom keys via `[[mgr.prepend_keymap]]` (layered on top of presets, not a
  full replacement). Ported from `~/dotfiles/ranger/rc.conf` — see the migration map below.
- `plugins/smart-enter.yazi/main.lua`: tiny inline plugin bound to `l`/`<Right>`/`<Enter>`/`o`.
  Enters a directory (internal `enter`) or opens a file (`open`). **This is the fix for
  folders launching ranger** — see Critical Rules.
- `plugins/zquery.yazi/main.lua`: ranger-style `cd` — `ya.input` prompt, runs
  `zoxide query -- <text>`, emits `cd <top match>`. No fzf picker (that was the complaint).
  Bound to `cd`. The bundled `zoxide` plugin (fzf picker) stays on `z`/`cD`.
- `init.lua`: `require("zoxide"):setup({ update_db = true })` so navigating in Yazi feeds the
  zoxide DB (mirrors ranger's zoxide plugin).
- `scripts/mount.sh`: udisks2 + fzf mount/unmount menu, bound to `dm` (replaces ranger's
  `ranger_udisk_menu` plugin). Must stay `chmod +x`.

## Critical Rules (learned the hard way)

- **Open-rule key is `url`, not `name`.** This Yazi version rejects `{ name = "..." }` with
  `at least one of 'url' or 'mime' must be specified` and falls back to preset settings.
  Always use `{ url = "*/" }` / `{ mime = "text/*" }`.
- **Opener order = default action.** If `edit` is listed first, files open in neovim. To use
  XDG defaults, `open` (xdg-open) must be first in the `use` list. Keep `edit`/`play` as
  later alternates (reachable via the interactive "open with" key, default `O`).
- **In THIS build (Yazi 26.5.6), `open` on a directory RUNS the opener** — it does NOT enter
  the dir. So a `*/` rule of `["edit", ...]` opened folders in neovim, and `["open", ...]`
  xdg-opened them → because `xdg-mime query default inode/directory` was `ranger.desktop`,
  every folder-open launched **ranger**. Two-part fix, both applied:
  1. `plugins/smart-enter.yazi` bound to `l`/`<Right>`/`<Enter>`/`o` → directories use the
     internal `enter` command (pure navigation, no opener, no ranger).
  2. nix-config `inode/directory` default flipped `ranger.desktop` → `yazi.desktop`, so any
     residual dir-open path (mouse double-click, other apps) opens Yazi, never ranger.
  Do **not** revert either without the other, or folders will launch an external app again.
- **Use `[[mgr.prepend_keymap]]`** (not `[[mgr.keymap]]`) to add keys without wiping the
  built-in defaults. A bare `[[mgr.keymap]]` block replaces the entire default set.
- **`[mgr]` vs `[manager]`:** older Yazi (< ~0.4) wants `[manager]`. If startup warns about
  an unknown `[mgr]` table, the installed Yazi is older — rename `[mgr]` → `[manager]` in
  both `yazi.toml` and `keymap.toml`. Current config targets the new `[mgr]`.

## Common Change Points

- **Change a keybinding:** add/edit a `[[mgr.prepend_keymap]]` block in `keymap.toml`
  (`on = [ ... ]`, `run = "..."`, `desc = "..."`). Run `ya` commands or `plugin <name>`.
- **Change default open app for a type:** reorder the `use` list for the matching `mime`/`url`
  rule in `yazi.toml`'s `[open]`. Put the desired opener first.
- **Add an opener program:** define it under `[opener]` (give it a name + `run`), then
  reference that name in an `[open]` rule's `use` list.
- **Toggle hidden-file default:** `[mgr] show_hidden`. Runtime toggle is the `.` key.
- **Add a quick-jump dir:** new `[[mgr.prepend_keymap]]` with `run = "cd /path"`.

## Plugin sync/async contract (bit us twice)

Per Yazi docs:
- `ya.input()` and `Command:output()` are **async-only** → the plugin `entry` must be plain
  **async** (NO `--- @sync entry`). Marking such a plugin `@sync` makes the input box fail to
  render and the task hang (you'll see "Run plugin 'x'" stuck in the quit dialog).
- `ya.emit()`, `ya.mgr_emit()`, and `cx.*` access are **sync** → a plugin that ONLY emits/reads
  state should be `--- @sync entry`.
- `ya.input` returns `(value, event)`; `event == 1` confirmed, `2` canceled, `3` changed.

Applied here: `smart-enter` is `@sync` (only reads `cx` + `ya.emit`); `zquery` is async
(`ya.input` + `Command:output` + `ya.emit`).

## Ranger → Yazi Migration Map

Config was ported from `~/dotfiles/ranger`. Keys (`keymap.toml`) and settings (`yazi.toml`):

| ranger | Yazi | Notes |
|---|---|---|
| `dm` (udisk_menu) | `dm` → `scripts/mount.sh` | udisks2 + fzf menu |
| `mk` mkdir | `mk` → `create` | end the name with `/` for a dir |
| `cd` (console z) | `cd` → `zquery` (type query, jump) | no fzf picker; `z`/`cD` = fzf picker |
| `iv`/`iV` (sxiv) | `iv` (sxiv cwd), `iV` (sxiv sel) | `sxiv -t` |
| `ex`/`eX`/`ec` (archives) | `ex`/`eX`/`ec` via `7z` | replaces `ranger_archives` |
| `dD` trash | `dD` → `remove` (also stock `d`) | |
| `du` ncdu | `du` → `shell ncdu` | |
| `yD` dragon | `yD` → `dragon-drop` | replaces `ranger_dragon` |
| `gd/gs/gp/gv` | same | + `gh` home, `gc` config, `gD` dotfiles |
| `yp/yd/yn/y.` | `Yp/Yd/Yn/Y.` → `copy …` | `Y` prefix; stock `y` stays = copy files |
| `v` mark toggle | `V` → `toggle_all` | stock `<Space>` toggles one |
| `default_linemode devicons` | built-in icons | no plugin needed |
| `preview_images method kitty` | built-in image preview | `[preview]` in yazi.toml |
| `colorscheme catppuccin_mocha` | flavor (see below) | not yet installed |

### Ranger plugin → Yazi equivalent

| ranger plugin | Yazi equivalent | Status |
|---|---|---|
| `ranger_devicons` | built-in Nerd Font icons | built in |
| `zoxide` | bundled `zoxide` plugin (`z`) | needs `zoxide` binary (present) |
| `ranger_archives` | `7z`-backed `ex`/`eX`/`ec` keymaps | done (p7zip present) |
| `ranger_udisk_menu` | `scripts/mount.sh` (`dm`) | done (udisks2 present) |
| `ranger_dragon` | `dragon-drop` shell keymap (`yD`) | done (dragon-drop present) |
| `kitty_icat_preview` | built-in image previewer | built in |
| `scope.sh` | built-in previewers (bat/file/poppler/ffmpegthumbnailer) | built in |

Optional upgrades (community plugins, install with `ya pkg add`):
`yazi-rs/plugins:smart-enter` (we ship our own inline copy instead), `ndtoan96/ouch.yazi`
(nicer multi-format compress/extract than raw `7z`), `yazi-rs/plugins:mount` (Lua mount UI).

## Colors / flavor (catppuccin-mocha)

The ranger `catppuccin_mocha` colorscheme is **not** ported as a hand-written `theme.toml`
(its schema drifts between Yazi versions and a single wrong key drops the whole config back
to presets). Use the official flavor instead — it ships a version-correct theme:

```bash
ya pkg add yazi-rs/flavors:catppuccin-mocha
```

That installs into `~/.config/yazi/flavors/` (i.e. this dotfiles dir → commit it). Then add a
`theme.toml` here containing only:

```toml
[flavor]
dark = "catppuccin-mocha"
```

Do not create that `theme.toml` until the flavor is installed, or Yazi errors "flavor not
found" and falls back to presets.

## Plugin Notes

- `z` (zoxide) and `Z` (fzf) use Yazi's **bundled** plugins — they work out of the box but
  require the `zoxide` and `fzf` **binaries** on PATH (both present in the nix flake).
- `smart-enter` here is a **local inline** plugin (`plugins/smart-enter.yazi/main.lua`), not a
  `ya pkg` install — it lives in this dotfiles dir and is version-pinned by us. It uses
  `ya.emit` (current API; `ya.mgr_emit` was deprecated in v25.5.28, `ya.manager_emit` before
  that) with fallbacks for older Yazi builds.
- Other non-bundled community plugins must be installed with `ya pkg add ...` before being
  bound, or the keybinding errors at invocation. Do **not** bind core navigation keys to an
  uninstalled plugin — it breaks basic movement.

## Debug Flow

### Yazi prints a TOML parse error and "continue with preset settings"

The config failed to load and Yazi is running on defaults (your customizations are inactive).
- Read the line/column in the error. Most common cause here: `name` used instead of `url` in
  an `[open]` rule, or `[manager]`/`[mgr]` table-name mismatch with the installed version.
- Fix the offending line, relaunch `yazi`. A clean start with no banner = config loaded.

### Files open in the wrong app (e.g. neovim instead of GUI default)

- Check the first opener in the matching `[open]` rule — it's the default. Move `open`
  (xdg-open) to the front for XDG behavior.
- Verify the system XDG default itself: `xdg-mime query default <mime>`. Yazi's `open`
  delegates to `xdg-open`, so a wrong system default surfaces here too.

### A keybinding does nothing / errors

- `ya` not on PATH, or the bound `plugin <name>` isn't installed. Confirm with `which ya`
  and `ya pkg list`.
- Press `~` (or `?`) inside Yazi to see the live, merged keymap and confirm the binding
  registered.

### Config edits don't apply

- Confirm the symlink: `readlink ~/.config/yazi` should point at `~/dotfiles/yazi`. If it
  points into `/nix/store`, it was created by `home.file` instead of `mkOutOfStoreSymlink` —
  fix via `links.nix` (`configApps`), not `home.file`.
- Yazi reads config at startup; fully quit and relaunch after edits.

## Change Rules

- Make the smallest change that fixes the issue; keep `prepend_keymap` for additions.
- Keep `open` first in file rules so XDG defaults are honored — do not regress to `edit`-first.
- Keep this dir an out-of-store symlink (writable). Do not let any home-manager
  `programs.*`/`services.*` module write into `~/.config/yazi` — that triggers the
  "outside $HOME" failure documented in `nix-config/AGENTS.md`.
- Don't bind keys to non-bundled plugins without installing them first.
