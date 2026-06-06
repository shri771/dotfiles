# Nix-Config Agent Runbook

This repo is a NixOS + home-manager flake deployed at `/etc/nixos` (system) and `~/.config/home-manager` is *not* used — everything is driven from this flake. Hostname for the active machine is `shri-nix`; primary user is `shri`.

## Files That Matter

- `flake.nix`: inputs (`nixpkgs` 26.05, `nixpkgs-unstable`, `home-manager` 26.05, `disko`, `neovim-nightly-overlay`), `nixosConfigurations.shri-nix` and `.iso`, standalone `homeConfigurations."shri@shri-nix"` and `"tst@shri-nix"`.
- `nixos/configuration.nix`: system-wide config (Hyprland, pipewire, tlp, bluetooth, fish, nix-ld, XDG portal, GNOME keyring, KDE/Plasma off, Docker-Container imports, user imports).
- `nixos/hardware.nix` / `nixos/hardware-configuration.nix` / `nixos/disk-config.nix`: machine-specific; imported from `flake.nix`, **not** from `configuration.nix`, so the ISO build can re-use `configuration.nix` without inheriting disk layout.
- `nixos/iso.nix`: live ISO entry; integrates `home-manager.nixosModules.home-manager` (the main `shri-nix` build does **not**).
- `home-manager/home.nix`: user `shri` entry; imports every `modules/home-manager/*` file.
- `home-manager/tst-home.nix`: user `tst` entry (test/secondary).
- `modules/home-manager/core.nix`: nixpkgs config (overlays + unfree), neovim, gnome-keyring, kdeconnect, batsignal, `xdg.mimeApps`, `xdg.enable`, `xdg.desktopEntries`, `home.sessionVariables`, termfilechooser config.
- `modules/home-manager/links.nix`: out-of-store symlinks from `~/dotfiles/<app>` into `~/.config/<app>` (hypr, kitty, ranger, fish, nvim, waybar, etc.). Listed in the `configApps` array; tmuxifier layouts are also linked here.
- `modules/home-manager/theme.nix`: GTK/Qt/Kvantum/kdeglobals theming.
- `modules/home-manager/git.nix`: git identity + config.
- `modules/home-manager/pkgs/base.nix`: core user packages (incl. inline `wlctl` rust derivation, `unstable` channel handle, ranger, dolphin, kdePackages, portals).
- `modules/home-manager/pkgs/extra.nix`: optional/extra user packages.
- `modules/nixos/users/shri.nix` / `tst.nix`: user accounts, groups, shell.
- `modules/nixos/sddm.nix`: login manager.
- `modules/home-manager/rclone-gdrive.nix`: `shri`-specific Home Manager user units for Google Drive via rclone (`shri77:`, `/home/shri/Documents`, mount at `/home/shri/Drive/Shri77`).
- `modules/nixos/Docker-Container/{vaultwarden,linkwarden}.nix`: containerised services.
- `docs/rclone-gdrive.md`: operator guide for `rclone config`, first `--resync`, mount, timer, script locations, and verification commands.
- `modules/nixos/user-packages.nix`: defined but **not currently imported** from `configuration.nix` — verify imports before relying on it.
- `overlays/default.nix`: three overlays — `additions` (everything in `pkgs/`), `modifications` (currently empty), `unstable-packages` (exposes `pkgs.unstable`).
- `pkgs/default.nix`: custom `callPackage` entries (currently empty scaffold).

## Exact Change Points

### Add or change a system-level setting (services, kernel, hardware, fonts)

Edit `nixos/configuration.nix` or add a new module under `modules/nixos/` and import it from `configuration.nix`'s `imports` list.

Examples:

- `services.tailscale.enable = true;` (top level of `configuration.nix`)
- `programs.steam.enable = true;`
- New module: `modules/nixos/my-service.nix`, then `../modules/nixos/my-service.nix` in the `imports` list.
Rules:

- System-only options (`services.*`, `programs.*` outside HM, `boot.*`, `networking.*`, `hardware.*`) belong here. HM has its own `services.*` namespace — do not confuse the two.
- Machine-specific facts (disks, GPU) go in `nixos/hardware.nix` / `disk-config.nix`, not `configuration.nix`, so the ISO can re-use `configuration.nix`.
- New host: add an entry to `nixosConfigurations` in `flake.nix`, do **not** edit `shri-nix` to be host-conditional.

### Add or change a user-level setting (HM)

Edit a file under `modules/home-manager/`. Add a new file there and import it from `home-manager/home.nix` if it doesn't fit an existing module.

Examples:

- New MIME default: `modules/home-manager/core.nix` → `xdg.mimeApps.defaultApplications."<mime>" = "<foo>.desktop";`
- New custom `.desktop` entry: `modules/home-manager/core.nix` → `xdg.desktopEntries.<name> = { ... };` (requires `xdg.enable = true;` in the same module — already set).
- New symlinked dotfile dir: add the directory name to the `configApps` list in `modules/home-manager/links.nix`.
- New user package: append to the list in `modules/home-manager/pkgs/base.nix` (or `extra.nix`).
- New user service: `services.<foo>.enable = true;` in `core.nix` or a new module imported from `home.nix`.

Rules:

- `xdg.desktopEntries`, `xdg.dataFile`, `xdg.configFile` (writes under `~/.local/share`/`~/.config`) require `xdg.enable = true;` — without it they are silent no-ops.
- `xdg.mimeApps` works without `xdg.enable`.
- `links.nix` uses `config.lib.file.mkOutOfStoreSymlink` — those entries point at the live `~/dotfiles/<name>` directory and are writable; do not migrate them to `home.file.<x>.source` (which would make them read-only nix-store symlinks).
- The two HM users (`shri`, `tst`) are configured independently via `home-manager/home.nix` and `home-manager/tst-home.nix`. Changes meant for both go in a shared module under `modules/home-manager/` and get imported from both entry files.
- If a user service should apply only to `shri`, import that module only from `home-manager/home.nix`, not `tst-home.nix`.

### Add a custom package

Edit `pkgs/default.nix`.

Rules:

- Use `pkgs.callPackage ./<name> { }` and put the derivation in `pkgs/<name>/default.nix`.
- Automatically exposed via the `additions` overlay (`overlays/default.nix`) once added — no flake edit required.
- For a quick one-off derivation used by only one user module, defining it inline in a `let` block (as `wlctl` is defined in `modules/home-manager/pkgs/base.nix`) is acceptable.

### Modify an existing nixpkgs package

Edit the `modifications` overlay in `overlays/default.nix`.

Rules:

- Use `prev.<pkg>.overrideAttrs` for source/build-flag tweaks, `prev.<pkg>.override` for argument substitution.
- Pin versions only when you have a reason; prefer following nixpkgs.

### Pull a package from unstable

Reference `pkgs.unstable.<pkg>` anywhere overlays are active (any module). The `unstable-packages` overlay in `overlays/default.nix` exposes the channel.

### Add a Docker-managed service

Put it in `modules/nixos/Docker-Container/<service>.nix` and import it from the `imports` list in `nixos/configuration.nix`.

Rules:

- Match the style of the existing `vaultwarden.nix` / `linkwarden.nix`.
- Containers go through `virtualisation.oci-containers` — verify `virtualisation.docker.enable` (or podman) is on in `configuration.nix` before adding the first container.
- Docker bridge networking is handled in `nixos/configuration.nix` under `networking.firewall`: `docker0` is listed in `trustedInterfaces`, and `extraCommands` installs an iptables wildcard rule for custom Docker bridges named `br-<id>`.

## Current External Dependencies

Required by current config:

- `nixpkgs` 26.05 and `nixpkgs-unstable` (flake inputs).
- `home-manager` release-26.05 (flake input).
- `disko` (flake input) — used for declarative disk layout via `nixos/disk-config.nix`.
- `neovim-nightly-overlay` (flake input; overlay line is currently commented out in `configuration.nix` but the input is fetched).
- `xdg-desktop-portal-hyprland`, `kdePackages.xdg-desktop-portal-kde`, `xdg-desktop-portal-termfilechooser` — extra portals in `configuration.nix`.
- `kitty` — termfilechooser's bundled `ranger-wrapper.sh` invokes `kitty` as `$TERMCMD`; the `ranger.desktop` entry in `core.nix` also launches `kitty --class ranger -e ranger`.

Referenced but not vendored in this repo:

- `~/dotfiles/<app>` directories listed in `modules/home-manager/links.nix` (`configApps`) — these are out-of-store symlinks, not part of the nix-store generation. Removing the directory in `~/dotfiles` will not break evaluation but will leave dangling links in `~/.config`.
- `~/dotfiles/scripts/tmuxifier` — out-of-store symlink for `~/.tmuxifier/layouts`.

Optional runtime helpers:

- `dolphin` (and `dolphin-plugins`) — installed via `modules/home-manager/pkgs/base.nix`, no longer the default `inode/directory` handler.
- `rclone` remote config at `~/.config/rclone/rclone.conf` — required for `modules/home-manager/rclone-gdrive.nix`; secrets/OAuth tokens are **not** stored in Nix.
- `~/dotfiles/scripts/rclone-gdrive/` — external helper scripts for mount and Documents sync; not vendored in this repo and must be kept in sync manually.

## Rclone / Google Drive Plan

Target layout:

- local working tree: `/home/shri/Documents`
- Google Drive remote path: `shri77:Document`
- browse mount: `/home/shri/Drive/Shri77`

Execution path:

1. Configure the `shri77` remote with `rclone config` outside Nix.
2. Run `home-manager switch --flake .#shri@shri-nix` so `modules/home-manager/rclone-gdrive.nix` installs the `shri` user units.
3. Run `systemctl --user start rclone-documents-resync.service` once to establish bisync state.
4. Enable `rclone-gdrive-mount.service` for continuous browsing access.
5. Enable `rclone-documents-sync.timer` for recurring two-way sync.

Why it is split this way:

- `rclone mount` is good for browsing but should not be treated as the sync source of truth.
- `rclone bisync` should target the remote path directly (`shri77:Document`), not the mounted FUSE path.
- keeping `rclone.conf` out of Nix avoids leaking OAuth credentials into the store.

## Precise Debug Flow

### A change to `nixos/configuration.nix` or `modules/nixos/*` didn't take effect

Run:

```bash
sudo nixos-rebuild switch --flake .#shri-nix
```

Then verify:

```bash
nix flake check
nix eval .#nixosConfigurations.shri-nix.config.<option.path>
sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -5
```

Interpretation:

- New generation appears → rebuild worked; the runtime service may still need a reload.
- `No changes` from `nix-env --list-generations` → the build was a no-op; the change probably isn't reachable (missing import, wrong attribute path).

If the expected runtime behaviour doesn't appear:

- Confirm the affected service is running the new config: `systemctl status <foo>.service` and check the `ExecStart=` store path.
- Long-lived user services (notably `xdg-desktop-portal.service`) persist across logout/login because user systemd is kept by `loginctl enable-linger` / by default in Hyprland sessions. Restart explicitly: `systemctl --user restart xdg-desktop-portal.service`.

### A change to `modules/home-manager/*` didn't take effect

`shri-nix` does **not** integrate HM into the NixOS build (only `iso` does). HM runs independently.

Run:

```bash
home-manager switch --flake .#shri@shri-nix
```

Then verify:

```bash
nix profile history --profile ~/.local/state/nix/profiles/home-manager | tail
readlink -f ~/.config/<file>
ls -la ~/.local/share/applications/
```

Interpretation:

- New numbered generation → rebuild worked; live files now resolve to the new store path.
- `~/.local/share/applications/<name>.desktop` missing after adding `xdg.desktopEntries.<name>` → `xdg.enable = true;` not set in any imported HM module.
- MIME default not updated → check `~/.config/mimeapps.list` for the actual line; check that no stale `~/.local/share/applications/mimeapps.list` is shadowing.

### A custom package fails to build

Run:

```bash
nix build .#<pkg>
nix flake check
```

Then check:

- `hash`/`cargoHash`/`vendorHash` values (most common cause of inline derivation breakage — e.g. `wlctl` in `pkgs/base.nix`); update with the value reported by the build error.
- Overlay ordering — `additions` runs before `modifications`; `unstable-packages` exposes `pkgs.unstable` and must be present for any reference to `pkgs.unstable.*`.
- Source `rev`/`hash` for `fetchFromGitHub` — bump both together.

### A symlinked dotfile dir is empty or missing in `~/.config`

Check `modules/home-manager/links.nix`.

Questions:

- Is the directory name in the `configApps` list?
- Does `~/dotfiles/<name>` exist on disk?
- Is `~/.config/<name>` a symlink pointing back into `~/dotfiles/<name>`? Run `readlink ~/.config/<name>`.

If the symlink points into `/nix/store/...`, it was created by `home.file.*.source` rather than `mkOutOfStoreSymlink` — fix by routing it through `links.nix`.

### Portal / file-chooser misbehaviour

Check `nixos/configuration.nix` (`xdg.portal`) and `modules/home-manager/core.nix` (`xdg-desktop-portal-termfilechooser/config`).

Run:

```bash
cat /etc/xdg/xdg-desktop-portal/hyprland-portals.conf
journalctl --user -u xdg-desktop-portal -f
systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-hyprland.service
```

Interpretation:

- `hyprland-portals.conf` matches the nix config but the wrong picker still opens → portal daemon is stale; restart it.
- `XDG_CURRENT_DESKTOP=Hyprland` but the file is `hyprland-portals.conf` — fine, the portal lowercases the desktop name when looking up the conf.

### Rclone mount or sync failed

Check `modules/home-manager/rclone-gdrive.nix`, `~/.config/rclone/rclone.conf`, and `~/dotfiles/scripts/rclone-gdrive/`.

Run:

```bash
home-manager switch --flake .#shri@shri-nix
systemctl --user status rclone-gdrive-mount.service
systemctl --user status rclone-documents-sync.service
systemctl --user status rclone-documents-sync.timer
journalctl --user -u rclone-gdrive-mount.service -n 100 --no-pager
journalctl --user -u rclone-documents-sync.service -n 100 --no-pager
rclone lsd shri77:
```

Interpretation:

- `config file not found` / auth errors → `rclone config` has not been completed for user `shri`.
- mount service active but `/home/shri/Drive/Shri77` is empty → the remote is reachable but the expected Drive path may differ from `shri77:Document`.
- `bisync` asks for `--resync` or reports missing listings → run `systemctl --user start rclone-documents-resync.service` once after initial setup or after state corruption.
- timer is active but sync never runs → confirm `systemctl --user list-timers | rg rclone-documents-sync` and that the user session or linger is active.

## Issue Tracking Format

Use this exact structure when investigating or fixing a problem.

### Issue

One sentence stating the user-visible failure.

Example:

`Browser upload dialogs and folder-open intents still launch Dolphin after switching the default file manager to ranger.`

### Impact

One sentence stating what is broken and where.

Example:

`Despite the xdg.mimeApps and portal routing being correct in the rebuilt config, neither file pickers nor xdg-open call ranger.`

### Root Cause

State the precise failing condition.

Example:

`modules/home-manager/core.nix declared xdg.desktopEntries.ranger but did not set xdg.enable = true, so home-manager skipped writing ~/.local/share/applications/ranger.desktop; the long-running xdg-desktop-portal.service additionally still held the pre-rebuild portals.conf in memory.`

### Fix

State the exact code or config change.

Example:

`Added xdg.enable = true; to the same block in modules/home-manager/core.nix, then ran systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-hyprland.service after the next home-manager switch.`

### Why This Works

State the execution-path reason, not just the symptom.

Example:

`xdg.desktopEntries is gated on xdg.enable; with it on, home-manager generates the .desktop file and the activation step links it into ~/.local/share/applications, where xdg-open finds it ahead of the ranger-package-provided entry. Restarting the portal daemon makes it reread hyprland-portals.conf, which already routed FileChooser to termfilechooser after nixos-rebuild.`

### Verification

List the exact checks run.

Example:

- `nix flake check`
- `home-manager switch --flake .#shri@shri-nix`
- `cat ~/.local/share/applications/ranger.desktop`
- `xdg-mime query default inode/directory`
- `xdg-open ~` (expect kitty + ranger to open)
- trigger a browser upload (expect kitty titled `termfilechooser` to open)

## Change Rules

- Make the smallest change that fixes the issue.
- Prefer adding to an existing module over creating a new one for a single option; split into a new module only when there's a coherent grouping.
- System options (`services.*`, `boot.*`, `programs.*` outside HM) belong under `nixos/` or `modules/nixos/`; user options belong under `modules/home-manager/`. Do not duplicate the same option across both layers.
- Keep `nixos/configuration.nix` free of machine-specific facts so the ISO build keeps working.
- Do not convert `mkOutOfStoreSymlink` entries in `links.nix` to `home.file.*.source` — the live config under `~/dotfiles` is intentionally writable.
- After any change that touches XDG, portals, or services, verify with `systemctl --user status <unit>` and `journalctl --user -u <unit>` rather than relying on logout/login alone.
- Do not remove unstable-channel references, overlay entries, or flake inputs unless you grep the whole tree first and confirm zero usages.
