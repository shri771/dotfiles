# Hyprland Dotfiles Agent Runbook

This directory is symlinked from `~/.config/hypr` via `modules/home-manager/links.nix` in the nix-config flake (see `~/dotfiles/nix-config/AGENTS.md`). Files here are **writable in place** — `mkOutOfStoreSymlink` points the live config back at `~/dotfiles/hypr`, so edits take effect after a Hyprland reload, not a rebuild. The active session is `shri@shri-nix` on NixOS.

`hyprland.conf` is the entry point. It only sources files from `configs/` and `UserConfigs/` — nothing here is read by Hyprland unless one of those two sources reaches it.

## Files That Matter

- `hyprland.conf`: top-level entry. Sources `configs/{Settings,Keybinds}.conf` then every `UserConfigs/*.conf`. The split is intentional: `configs/` is treated as upstream (avoid editing on update), `UserConfigs/` is user-owned.
- `configs/Settings.conf`: minimal — only `exec-once = initial-boot.sh`. Real settings live in `UserConfigs/UserSettings.conf`.
- `configs/Keybinds.conf`: default keybinds (window/workspace navigation, screenshots, media keys, volume/brightness, group/cycle, mouse drag bindings). The "do not touch on update" file.
- `UserConfigs/UserSettings.conf`: input (kb_layout `us,us` variant `dvp,`, `grp:ctrls_toggle` to switch layouts), touchpad, touchdevice, tablet, `dwindle`/`master` layout (active layout is `master`), `misc` (vrr=2, swallow `^(kitty)$`), `binds`, `xwayland`, `cursor`.
- `UserConfigs/UserKeybinds.conf`: user-level keybinds (app launchers, rofi `ALT+F`, pyprland scratchpads, kitty/vivaldi/ranger/notion launchers).
- `UserConfigs/UserDecorAnimations.conf`: borders, gaps, rounding, blur, shadow, group bar, animations. Sources `wallust/wallust-hyprland.conf` for `$color*`. Animations currently `enabled = false`.
- `UserConfigs/Startup_Apps.conf`: remaining `exec-once` lines after the uwsm migration — `awww`-daemon (renamed from `swww` in 26.05), waybar, ags, nm-applet, blueman-applet, ydotoold, hypridle, pypr, kanshi, `temp_show.sh`, `xhost +SI:localuser:root`. Everything else (gnome-keyring, polkit agent, swaync, kdeconnect-indicator, cliphist watchers, swappy) moved to HM-managed systemd user units — see "Daemons now run as systemd user units" below.
- `UserConfigs/ENVariables.conf`: GDK/QT backends, XDG_*, scale factors, electron ozone hint, hyprland-qt-support QML path. NVIDIA block is commented out.
- `UserConfigs/Monitors.conf`: only generic `preferred,auto,1` lines. Per-monitor wakeup workaround discussed in `Laptops.conf` (lid handling) routes overrides into `UserConfigs/LaptopDisplay.conf`.
- `UserConfigs/Laptops.conf`: ASUS-specific keybinds (kbd brightness, `xf86Launch1` = rog-control-center, `xf86Launch3` = asusctl led-mode, `xf86Launch4` = asusctl profile), brightness/touchpad scripts, touchpad device name `asue1209:00-04f3r319f-touchpad`, lid-switch handling (currently commented).
- `UserConfigs/LaptopDisplay.conf`: target of the lid-switch `echo > ...` lines in `Laptops.conf`. Empty until lid handling is enabled.
- `UserConfigs/WindowRules.conf`: every `windowrule` (workspace assignment, floating/centering, opacity, size, pin/no_anim/idle_inhibit). Note `ranger` rules at the bottom — used by the termfilechooser flow (see nix-config AGENTS.md, "Portal / file-chooser misbehaviour").
- `UserConfigs/WorkspaceRules.conf`: only `workspace=1,monitor:eDP-1,margins:0,0,0,0` is active; the rest are commented examples.
- `hyprlock.conf` / `hyprlock-1080p.conf`: lockscreen layout. `hyprlock.conf` sources `wallust/hyprlock-colors.conf` (frozen palette from the *previous* wallpaper — see `scripts/WallustSwww.sh`).
- `hypridle.conf`: 4 listeners — dim at 295s, lock at 300s (skipped if playerctl is playing), dpms off at 310s, `before_sleep_cmd` invokes hyprlock.
- `pyprland.toml`: scratchpad definitions (term, whatsie/zapzap, mixer/pavucontrol, share/rquickshare, cal/qalculate-gtk, mission/missioncenter, file/dolphin, kde/kdeconnect-app, kitty/wlctl). Triggered from `UserKeybinds.conf` via `pypr toggle <name>`.
- `wallust/wallust-hyprland.conf`: live `$color0..$color15` written by `wallust run`. Sourced by `UserDecorAnimations.conf`.
- `wallust/hyprlock-colors.conf`: snapshot copied from `wallust-hyprland.conf` *before* the next `wallust run` overwrites it (see `scripts/WallustSwww.sh:60-62`). Sourced by `hyprlock.conf` so the lock screen keeps the *previous* desktop palette.
- `initial-boot.sh`: runs once, guarded by `~/.config/hypr/.initial_startup_done`. Applies initial wallpaper via swww, wallust, gsettings (gtk/icon/cursor/color-scheme), kvantum theme, kb layout, waybar style symlink.
- `scripts/start-hyprland.sh`: SDDM entry shim. Starts gnome-keyring-daemon then `exec start-hyprland` (the upstream wrapper). Referenced by `modules/nixos/sddm.nix` in the nix-config flake.
- `scripts/WallustSwww.sh`: wallpaper-change pipeline. Resolves current wallpaper from `~/.cache/swww/<monitor>`, mirrors it into `~/.config/rofi/.current_wallpaper` and `~/.config/hypr/wallpaper_effects/.wallpaper_current`, snapshots the *current* `wallust-hyprland.conf` to `hyprlock-colors.conf` (intentional — lock screen lags behind by one wallpaper), then `wallust run -s` (foreground, so Refresh.sh sees regenerated templates).
- `scripts/Refresh.sh`: restarts waybar/swaync/rofi after color/template regeneration. Invoked at the end of `WallustSwww.sh` and from the `SUPER SHIFT R` keybind.
- `scripts/ChangeLayout.sh`: toggles `general:layout` between `master` and `dwindle` *and* rebinds `SUPER+J/K/O` to match the active layout's idioms. Bound to `$mainMod CTRL+L`.
- `scripts/GameMode.sh`: zero-cost mode — disables animations/shadow/blur/rounding/gaps/borders and forces opacity 1.0, then `swww kill`. Re-enabling rehydrates wallpaper + wallust + refresh. Bound to `$mainMod SHIFT+G`.
- `scripts/start_gnome_keyring.sh`, `Keyring-NixOS.sh`: GNOME keyring start variants. **No longer active** — keyring is started by HM's `services.gnome-keyring` and unlocked by PAM (see nix-config AGENTS.md). The `keyring.sh` variant was deleted in the uwsm migration.
- `scripts/Polkit-NixOS.sh`: **deleted** in the uwsm migration. Replaced by `hyprpolkitagent` which is activated via a wants-symlink from `core.nix`.
- `scripts/PortalHyprland.sh`: xdg-desktop-portal restart helper. Useful when portal config in nix-config changes but the live daemon is stale.
- `scripts/temp_show.sh` + `scripts/temp_sensor` (symlink to `/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input`): CPU temp readout for waybar/notifications. The symlink target is **hardware-specific** — if `hwmon5` reassigns after a kernel update, this breaks silently.
- `scripts/lock_suspend.sh`, `LockScreen.sh`, `Hypridle.sh`: lockscreen entry points; `hypridle.conf` calls `hyprlock` directly so these are only used by manual keybinds / wlogout.
- `scripts/ScreenShot.sh`, `ScreenRecord.sh`, `ScreenCapture.sh` flow: grim/slurp + wf-recorder. Output dirs are hardcoded in the scripts.
- `scripts/Volume.sh`, `Brightness.sh`, `BrightnessKbd.sh`, `MediaCtrl.sh`: special-key handlers, bound from `configs/Keybinds.conf` (volume/media) and `UserConfigs/Laptops.conf` (brightness).
- `scripts/SwitchKeyboardLayout.sh`, `toggle_kylayout.sh`: kb layout switching. Initial layout is set in `UserSettings.conf` (`us,us` / `dvp,` / `grp:ctrls_toggle`); these scripts toggle at runtime.
- `scripts/BluetoothRofi.sh`, `connect_realmebuds.sh`, `connect_hpkeyboard.sh`, `restart-bluetooth.sh`: BT pairing helpers. The `realmebuds` toggle is also bound to `$mainMod CTRL+B` and routes through `~/dotfiles/scripts/system/toggle_realmebuds_bind.sh` (lives outside this directory).
- `scripts/RofiEmoji.sh` (~488KB), `RofiSearch.sh`, `KeyHints.sh`, `KeyBinds.sh`, `Wlogout.sh`: rofi-based menus.
- `scripts/ClipManager.sh`: cliphist-backed clipboard rofi menu. Watchers are started in `Startup_Apps.conf`.
- `scripts/WaybarLayout.sh`, `WaybarStyles.sh`, `WaybarCava.sh`, `RefreshNoWaybar.sh`, `toggle_waybar.sh`: waybar style/layout switching. Operates on `~/.config/waybar/style.css` (symlink target).
- `UserScripts/`: user-owned helpers — `QuickEdit.sh` (rofi-based edit menu for hypr configs), `WallpaperSelect.sh`/`WallpaperRandom.sh`/`WallpaperAutoChange.sh`/`WallpaperEffects.sh` (wallpaper picker family), `RofiBeats.sh` (online music), `RofiCalc.sh`, `Weather.{sh,py}`, `ZshChangeTheme.sh`.
- `wallpaper_effects/`: ImageMagick output cache for `WallpaperEffects.sh`. `.wallpaper_current` is the canonical "what's on screen right now" path used by `hyprlock.conf`.
- `session/hypr.session`, `hypr.session`, `hyprsession.conf`: session-save artifacts; not actively read by hyprland.conf.
- `scratchpads.json`: legacy pyprland scratchpad format; current scratchpads are defined in `pyprland.toml`.
- `application-style.conf`, `con`, `check_temp.txt`, `tubely.db`, `v2.3.9`: stray/unused files. Do not source them from `hyprland.conf`.

## Daemons now run as systemd user units (uwsm migration)

NixOS sets `programs.hyprland.withUWSM = true` and SDDM defaults to `hyprland-uwsm`. uwsm sets up the session via `graphical-session.target`, so daemons that follow the Hyprland session lifecycle belong as systemd user units, not `exec-once` in `Startup_Apps.conf`.

Daemons that were previously `exec-once` and are now systemd-managed:

| Daemon | Activation point |
|---|---|
| `gnome-keyring` | HM `services.gnome-keyring` + PAM unlock (`security.pam.services.login.enableGnomeKeyring`). |
| `kdeconnect-indicator` | HM `services.kdeconnect.indicator = true`. |
| `cliphist` text + image watchers | HM `services.cliphist.enable`. |
| `swaync` | Wants-symlink in `core.nix` — `services.swaync.enable` would write `~/.config/swaync/config.json` and collide with the `mkOutOfStoreSymlink` from `links.nix`. |
| `hyprpolkitagent` | Wants-symlink in `core.nix` (no HM module exists yet). Replaces the pre-uwsm `polkit_gnome` + `Polkit-NixOS.sh` chain. |

`swappy` was also dropped from `Startup_Apps.conf` — it's an interactive screenshot annotation tool, not a daemon.

Deleted from `scripts/` because their job is now done by HM/PAM/systemd:

- `scripts/keyring.sh`
- `scripts/Polkit-NixOS.sh`

What still runs from `Startup_Apps.conf` and why each one was kept there:

- `awww`-daemon (was `swww` before the 26.05 rename) — wallpaper daemon, must precede `swww img`/`wallust` calls.
- `temp_show.sh` — custom helper, not a packaged daemon.
- `xhost +SI:localuser:root` — XWayland access control, no systemd equivalent.
- `kanshi` — has an HM module but would write `~/.config/kanshi/config` and collide with the symlink from `links.nix`. Same conflict class as `swaync`.
- `waybar` — same write-conflict risk on `~/.config/waybar`. Migrate via `programs.waybar.enable = true; programs.waybar.systemd.enable = true;` **only if** you also remove `"waybar"` from `configApps` in `links.nix`.
- `nm-applet`, `blueman-applet`, `ags`, `pypr`, `ydotoold`, `hypridle` — no HM module conflict but left as exec-once for now. Each could be promoted to `uwsm app -- <cmd>` to run in its own systemd scope without going through HM.

If `app-picom@autostart.service` reappears in the failed-units list, the suppressing override is in `nix-config:modules/home-manager/core.nix` (`xdg.configFile."autostart/picom.desktop"` writes `Hidden=true`). AwesomeWM's `autostart.lua` is the sole picom launcher.

## Exact Change Points

### Add or change a keybind

Decide which file owns it:

- Window-management / navigation / screenshots / media / volume / brightness / workspace switching → `configs/Keybinds.conf` (the upstream-style file).
- App launchers, rofi menus, pyprland scratchpads, anything that runs a custom binary → `UserConfigs/UserKeybinds.conf`.
- Laptop hotkeys (`xf86*`, lid switch, asusctl) → `UserConfigs/Laptops.conf`.

Rules:

- Use `$mainMod` (= `SUPER`, defined at the top of `Keybinds.conf` and re-declared at the top of `UserKeybinds.conf`/`Laptops.conf`). Do not hardcode `SUPER`.
- For scripts, prefer `bash $scriptsDir/<name>.sh` — `$scriptsDir` is set at the top of each keybind file. `$UserScripts` is the parallel for `UserScripts/`.
- Locale-safe workspace switching uses keycodes (`code:10` = `1`, `code:11` = `2`, …, `code:49` = backtick). This pairs with the dvp kb_variant — keep the keycode binding when adding a workspace switch so a layout flip doesn't break it.
- After editing, reload Hyprland: `hyprctl reload`. Do not log out — the writable-symlink design means reload is sufficient.
- If a key binding conflicts (`bind` silently last-write-wins on duplicates), check `hyprctl binds` to verify which definition won.

### Add a startup application

Edit `UserConfigs/Startup_Apps.conf`. Add an `exec-once = <cmd> &` line. Group with the existing block (wallpaper / keyring / waybar / clipboard / hypridle / pypr).

Rules:

- For services that must run *before* anything else (keyring, portal env vars), keep them above `waybar &`. The current order is load-bearing for the keyring/agent chain.
- `swww-daemon` must be running before `swww img` is invoked. Already handled at the top of the file.
- Do not use `exec` (run on reload) for one-shot startups — use `exec-once` (run only at compositor start). `exec` is reserved for things like the `hyprctl setcursor` line that needs to re-apply on reload.

### Add or change a window rule

Edit `UserConfigs/WindowRules.conf`. Match the existing form: `windowrule = <rule>, match:class ^(...)$[, match:title ^(...)$]`.

Rules:

- The file uses the **new** `windowrule` syntax (Hyprland ≥ 0.42 — single namespace, no `windowrulev2`). Do not introduce `windowrulev2` lines.
- Class names are case-sensitive and must match `hyprctl clients` exactly. Use `^(Foo|foo)$` rather than guessing.
- Workspace assignment via `windowrule = workspace N silent` triggers on window *open*; combine with `match:title ...` only if the title is set before the rule needs to fire (some apps re-title late).
- Floating + sizing + centering for an app is three separate lines, all with the same `match:` — keep them grouped.

### Add a pyprland scratchpad

Edit `pyprland.toml`. Add a `[scratchpads.<name>]` block (command, class, size, position, lazy, focus). Then add a keybind in `UserKeybinds.conf`: `bind = <mods>, <key>, exec, pypr toggle <name>`.

Rules:

- `class` must match what the app actually reports — `hyprctl clients | rg <name>` after launching once.
- `lazy = true` keeps the app warm in the background. Use it for slow-launching apps (zapzap, dolphin). Avoid for short-lived tools where startup is cheap.
- After editing `pyprland.toml`, restart pypr: `pkill pypr && pypr &`. `hyprctl reload` does **not** reload pyprland.

### Change a layout / animation / decoration setting

Edit `UserConfigs/UserDecorAnimations.conf` (borders, gaps, rounding, blur, shadow, group bar, animations) or `UserConfigs/UserSettings.conf` (input, master/dwindle internals, misc, xwayland, cursor).

Rules:

- `col.active_border` / `col.inactive_border` / shadow colors must reference `$color*` from `wallust/wallust-hyprland.conf`. That file is regenerated on every wallpaper change — hardcoded hex will be ignored after the next regen.
- `animations.enabled = false` is intentional. `GameMode.sh` already toggles this at runtime; if you re-enable animations globally, the gamemode toggle still works but its first state will be inverted.
- `blur.special = true` applies blur to the special workspace — leave on if you use `$mainMod+U`.

### Change theme colors

You do **not** edit `wallust/wallust-hyprland.conf` directly — it's regenerated by `wallust run`. To change the palette:

- Change wallpaper (`SUPER+X` → `WallpaperSelect.sh`) — `WallustSwww.sh` regenerates the palette and `Refresh.sh` reloads downstream consumers.
- To force a regen against the current wallpaper: `~/.config/hypr/scripts/WallustSwww.sh`.
- To customize the template that `wallust` writes from: edit `~/.config/wallust/templates/hyprland.conf` (lives in the wallust config dir, not this repo).
- `hyprlock-colors.conf` is intentionally one wallpaper behind — see `WallustSwww.sh:60-62`. Do not "fix" this by copying live colors; it's how the lock screen keeps a stable palette across the unlock animation.

### Change monitor / lid behavior

- Generic monitor lines: `UserConfigs/Monitors.conf`. The active rules are `,preferred,auto,1` plus `,highrr,auto,1` and `,highres,auto,1` — they layer.
- Per-machine monitor: prefer adding a `monitor = eDP-1, ...` line at the top of `Monitors.conf` rather than relying on the generic `,preferred,...` fallback.
- Lid switch: see the commented examples in `UserConfigs/Laptops.conf` (lines 28-44). Two strategies are documented — direct `hyprctl keyword monitor "eDP-1, disable"` vs. writing to `LaptopDisplay.conf` and re-reading. Pick one; the second strategy is what `LaptopDisplay.conf` exists for.
- `kanshi` is also started from `Startup_Apps.conf` — its config (`~/.config/kanshi/config`) can override Hyprland's per-monitor placement. If a monitor change doesn't stick after `hyprctl reload`, check kanshi.

### Add a script

Drop it in `scripts/` (default/upstream) or `UserScripts/` (user-owned). `chmod +x`. Bind it from the keybind file that matches its purpose.

Rules:

- Shebang: `#!/usr/bin/env bash` (matches existing scripts). `sh` is not guaranteed — these are bash-only.
- Reference helpers via `$scriptsDir` / `$UserScripts` from the keybind file, not by absolute path.
- For NixOS-specific behavior (no FHS, no /usr/lib hits), follow the `Polkit-NixOS.sh` / `Keyring-NixOS.sh` / `UptimeNixOS.sh` pattern — these have NixOS-flavored counterparts to upstream scripts.
- Notification icon path used across the scripts: `$HOME/.config/swaync/images/bell.png`. Keep it consistent.

### Change the SDDM entry / how Hyprland is launched

Edit `scripts/start-hyprland.sh`. This is the file SDDM invokes (referenced by `modules/nixos/sddm.nix` in the nix-config flake — see that AGENTS.md before touching the wrapper).

Rules:

- The script must `exec start-hyprland` (the upstream crash-recovery wrapper), **not** `exec Hyprland` directly. Direct invocation skips crash recovery and safe-mode prompts.
- Any environment that must be in the Hyprland process's env (not just children) goes here — `exec-once` runs *after* Hyprland is up.

## Current External Dependencies

Binaries assumed to be on `$PATH` at session start (most are installed via the nix-config flake, see `~/dotfiles/nix-config/modules/home-manager/pkgs/base.nix`):

- `Hyprland`, `start-hyprland`, `hyprctl`, `hyprlock`, `hypridle`.
- `swww`, `swww-daemon`, `wallust` — wallpaper + palette pipeline.
- `waybar`, `rofi`, `ags`, `wlogout`, `nm-applet`, `blueman-applet`, `ydotoold` — startup apps still in `Startup_Apps.conf`.
- `swaync`, `hyprpolkitagent`, `kdeconnect-indicator`, `cliphist` — daemons activated as systemd user units via nix-config (see "Daemons now run as systemd user units").
- `kanshi` — output config daemon.
- `pypr` (pyprland) — scratchpad daemon.
- `kitty` — primary terminal; many keybinds and scratchpads hard-code it. `kitty-dropterm` and `kitty-wlctl` are class names, not separate binaries.
- `ranger`, `dolphin`, `vivaldi`, `notion-calender`, `qalculate-gtk`, `pavucontrol`, `zapzap`, `rquickshare`, `missioncenter`, `kdeconnect-app` — referenced from `UserKeybinds.conf` / `pyprland.toml`.
- `cliphist`, `wl-paste`, `copyq` — clipboard.
- `brightnessctl`, `playerctl`, `pactl`, `wpctl` — special-key scripts.
- `grim`, `slurp`, `wf-recorder`, `swappy` — screenshot/record.
- `asusctl`, `rog-control-center` — ASUS-only, only invoked from `Laptops.conf` keybinds (no-ops on non-ASUS hardware).
- `gnome-keyring-daemon` (via HM `services.gnome-keyring` + PAM unlock), `hyprpolkitagent` (via wants-symlink in `core.nix`). The pre-uwsm `polkit-gnome-authentication-agent-1` chain is gone — see "Daemons now run as systemd user units".
- `jq`, `awk`, `sed`, `notify-send` — shell-script dependencies.

Referenced but **not** in this directory:

- `~/dotfiles/scripts/system/toggle_realmebuds_bind.sh` — bound from `Keybinds.conf:25`.
- `~/.config/waybar/style/[Dark] Latte-Wallust combined.css` — `initial-boot.sh` symlinks this into `~/.config/waybar/style.css`. Must exist after the waybar dotfiles are linked.
- `~/.config/rofi/.current_wallpaper` — symlink target, written by `WallustSwww.sh`.
- `~/.cache/swww/<monitor>` — swww's own cache; `WallustSwww.sh` parses it to discover the current wallpaper.
- `/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input` — target of `scripts/temp_sensor`. Hardware-specific.

## Precise Debug Flow

### A change to a `.conf` file didn't take effect

Run:

```bash
hyprctl reload
```

Then verify:

```bash
hyprctl binds | rg '<the key combo you changed>'
hyprctl getoption <namespace>:<option>
hyprctl monitors
hyprctl clients
```

Interpretation:

- `hyprctl reload` exits non-zero or prints a parse error → syntax issue in one of the sourced files. The error names the file + line.
- Reload succeeded but the keybind still does the old thing → another `bind` line later in the source order wins. Last definition wins for the same key combo.
- The change is in `configs/Keybinds.conf` but doesn't apply → check `hyprland.conf` actually sources it (it does by default — only suspicious if someone reorganized).
- New option in `UserSettings.conf` ignored → option name typo; `hyprctl getoption <namespace>:<option>` returns the live value, compare against the wiki.

### `pyprland` scratchpad toggle does nothing

Run:

```bash
pgrep -a pypr
pkill pypr && pypr &
journalctl --user -t pypr -n 50 --no-pager  # if pypr is wrapped in a unit
```

Interpretation:

- `pypr` not running → `Startup_Apps.conf` line didn't fire, or pypr crashed. Restart manually.
- Running but toggle ignored → `class` in `pyprland.toml` doesn't match the actual window class. Launch the app once and `hyprctl clients | rg <name>` to see what class it reports, then update `pyprland.toml`.
- Toggle works once then breaks → `lazy = true` is keeping a dead process handle; restart pypr.

### Wallpaper changed but colors didn't update

Run:

```bash
~/.config/hypr/scripts/WallustSwww.sh
cat ~/.config/hypr/wallust/wallust-hyprland.conf | head
hyprctl reload
~/.config/hypr/scripts/Refresh.sh
```

Interpretation:

- `wallust-hyprland.conf` updated but Hyprland borders still old → reload didn't fire. `WallustSwww.sh` does **not** itself call `hyprctl reload`; the consumer (`Refresh.sh` or your keybind) must.
- `wallust-hyprland.conf` unchanged → `wallust run` failed silently; check `~/.cache/wallust/` for errors and that the wallpaper path actually exists.
- Lock screen colors lag by one wallpaper → **expected**. `hyprlock-colors.conf` is snapshot before `wallust run` overwrites. See `scripts/WallustSwww.sh:60-62`.

### Lock screen never engages on idle

Run:

```bash
pgrep -a hypridle
systemctl --user status hypridle  # only if managed as a unit
playerctl -a status
```

Interpretation:

- `hypridle` not running → not started by `Startup_Apps.conf` (line 43) or it crashed.
- Running but no lock → `hypridle.conf:20` skips lock if any player is "Playing". Pause media or kill the player.
- Lock fires but immediately unlocks → grace period (`hyprlock.conf` `general.grace = 1`) plus stray input. Increase grace if needed.

### `xf86*` keys do nothing

Run:

```bash
wev   # or libinput debug-events
hyprctl binds | rg -i 'xf86'
```

Interpretation:

- `wev` shows no key event → key is being eaten by the kernel / asusctl. Use `evtest`. Check that asusctl is configured to release the key.
- Event arrives but no bind fires → the bind for that exact code is missing or mistyped. Note `xf86KbdBrightnessDown`/`Up` (capital K-b-d) — they're case-sensitive.
- Bind exists but the script fails → run the script directly with `bash -x $scriptsDir/<name>.sh` to see the failure.

### `start-hyprland.sh` fails at SDDM

Hyprland's safe-mode prompt appears, or the session falls back to SDDM:

- Check the journal: `journalctl --user-unit graphical-session.target -b -e --no-pager`.
- Check Hyprland's own log: `cat ~/.cache/hyprland/hyprland.log | tail -200`.
- The `eval $(gnome-keyring-daemon --start)` line at the top of `scripts/start-hyprland.sh` will silently fail if gnome-keyring isn't on PATH at SDDM time — verify the unit env.
- `exec start-hyprland` (not `Hyprland`) is required for crash recovery. If someone changed this, restore the upstream wrapper.

### Temp readout in waybar shows nothing

```bash
ls -l ~/.config/hypr/scripts/temp_sensor
cat ~/.config/hypr/scripts/temp_sensor  # follows the symlink
```

`temp_sensor` is a symlink to `/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input`. After kernel updates, `hwmon5` may renumber. Find the new index:

```bash
for d in /sys/class/hwmon/hwmon*; do
  printf '%s -> %s\n' "$d" "$(cat $d/name 2>/dev/null)"
done
```

Then re-point the symlink: `ln -sf /sys/devices/platform/coretemp.0/hwmon/hwmonN/temp1_input ~/.config/hypr/scripts/temp_sensor`.

### A change in nix-config doesn't show up in `~/.config/hypr`

Not a debug flow for *this* directory — see `~/dotfiles/nix-config/AGENTS.md` "A symlinked dotfile dir is empty or missing in `~/.config`". The link is managed in `modules/home-manager/links.nix:configApps`. Edits **here** are live without rebuild; only adding/removing the symlink itself requires `home-manager switch`.

## Issue Tracking Format

Use this exact structure when investigating or fixing a problem.

### Issue

One sentence stating the user-visible failure.

Example:

`SUPER+CTRL+L toggles between master and dwindle layouts but the J/K window-navigation keys behave the same way in both layouts.`

### Impact

One sentence stating what is broken and where.

Example:

`After ChangeLayout.sh runs, J/K still cycle windows the dwindle way even in master mode, so master-layout navigation feels broken.`

### Root Cause

State the precise failing condition.

Example:

`scripts/ChangeLayout.sh:23-26 issues hyprctl keyword bind ... but the original SUPER+J/K binds from configs/Keybinds.conf:103-105 are movewindow direction binds, not cyclenext — the script never unbinds the movewindow variants, so both bindings coexist and the keymap dispatcher picks the first match.`

### Fix

State the exact code or config change.

Example:

`In scripts/ChangeLayout.sh, before each "hyprctl keyword bind ..." add a matching "hyprctl keyword unbind SUPER,<key>" for the movewindow variant, or move the J/K movewindow binds out of configs/Keybinds.conf into UserKeybinds.conf so ChangeLayout.sh owns them entirely.`

### Why This Works

State the execution-path reason, not just the symptom.

Example:

`hyprctl keyword bind appends; it does not replace a same-combo bind set by config. Only hyprctl keyword unbind removes a prior bind from the live keymap. Issuing unbind+bind pairs makes the dispatcher's resolution unambiguous regardless of which order configs/Keybinds.conf and ChangeLayout.sh ran in.`

### Verification

List the exact checks run.

Example:

- `hyprctl reload`
- `~/.config/hypr/scripts/ChangeLayout.sh` (expect notification "Dwindle Layout")
- `hyprctl binds | rg 'SUPER.*[JK]$'` (expect only the dwindle variant)
- Press SUPER+J — expect cyclenext, not movewindow
- Run ChangeLayout.sh again, repeat the bind check for master

## Change Rules

- Make the smallest change that fixes the issue. Hyprland's last-write-wins bind semantics mean small additions are safe; large rewrites cause silent shadowing.
- `configs/Keybinds.conf` and `configs/Settings.conf` are treated as upstream. Put new user bindings/options in `UserConfigs/User*.conf` so the upstream files stay diff-clean if JaKooLit's dotfiles change.
- Do not source new files from `hyprland.conf` unless absolutely necessary — keep the source order stable. Add to existing `UserConfigs/*.conf` files instead.
- `hyprctl reload` is your verification step. If it doesn't error, the syntax is good. If the runtime behavior is still wrong, it's a semantic bug, not a parse bug.
- Do **not** convert this directory to nix-managed files via `home.file.<x>.source` (which would make it read-only). The whole point of the `mkOutOfStoreSymlink` in the flake is that this directory is writable in place.
- After editing anything related to themes/colors (`UserDecorAnimations.conf`, `wallust/*`, `hyprlock*.conf`), do a wallpaper-change round-trip (`SUPER+X` or run `WallustSwww.sh` manually) to confirm the templates regenerate cleanly.
- ASUS-specific keybinds (`Laptops.conf`) are no-ops on non-ASUS hardware but won't break anything — leave them in unless the machine model changes.
- `pyprland.toml` requires a `pkill pypr && pypr &` reload, not `hyprctl reload`. Easy to forget.
- For NixOS-specific scripts (`Keyring-NixOS.sh`, `UptimeNixOS.sh`), do not "simplify" them to call the FHS paths — they exist because the FHS paths don't resolve here. `Polkit-NixOS.sh` was deleted in the uwsm migration; do not re-introduce a `/nix/store`-hunting hack.
- Treat `wallust/hyprlock-colors.conf` lagging by one wallpaper as a feature, not a bug. See `scripts/WallustSwww.sh:57-62` for the rationale.
- Do not remove `configs/`, `UserConfigs/`, or any file currently sourced by `hyprland.conf` without first grepping every script in `scripts/` and `UserScripts/` for references — many scripts re-source these for their own `$color*` lookups.
