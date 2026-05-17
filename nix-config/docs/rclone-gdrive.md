# Google Drive Rclone Setup

## Existing Scripts Found

The current ad hoc scripts under `~/dotfiles/scripts/startups/` were:

- `shri77_drive.sh`: mounts `shri77:` to a local folder
- `shri77_gdrive_sync.sh`: bisync for a Documents-style remote
- `shri77_docu_sync.sh`: document bisync watcher, but it uses the wrong local path (`/home/sh/Document`)

They confirm the intended remote naming:

- remote name: `shri77`
- Google Drive folder: `Document`

## Final Layout

- Local working folder: `/home/shri/Documents`
- Remote sync target: `shri77:Document`
- Browse mount: `/home/shri/Drive/Shri77`
- Mounted remote for browsing: `shri77:Document`
- Helper scripts folder: `~/dotfiles/scripts/rclone-gdrive/`
- `shri`-only Home Manager module: `modules/home-manager/rclone-gdrive.nix`
- Persistent user mount service: `rclone-gdrive-mount.service`
- Regular sync unit: `rclone-documents-sync.service`
- First-run bootstrap unit: `rclone-documents-resync.service`
- Periodic sync timer: `rclone-documents-sync.timer`

Mount and sync are intentionally separate:

- mount is for browsing the full Drive tree locally
- mount is now scoped to `shri77:Document` to avoid heavy full-Drive browsing in file managers
- bisync is for keeping `/home/shri/Documents` and `shri77:Document` in sync
- the Home Manager user units call the helper scripts from `~/dotfiles/scripts/rclone-gdrive/`

## One-Time Setup

1. Apply the Home Manager config for `shri`:

```bash
home-manager switch --flake .#shri@shri-nix
```

2. Create the rclone remote interactively:

```bash
rclone config
```

Use these values:

- remote name: `shri77`
- storage type: `drive`
- authenticate against your Google account

3. Verify the remote before enabling sync:

```bash
rclone lsd shri77:
rclone lsd shri77:Document
```

If `shri77:Document` does not exist yet, create it:

```bash
rclone mkdir shri77:Document
```

## First Sync

Run the bootstrap sync once. This creates the bisync state and treats both sides as authoritative for initialization:

```bash
systemctl --user start rclone-documents-resync.service
```

Check the result:

```bash
systemctl --user status rclone-documents-resync.service
journalctl --user -u rclone-documents-resync.service -n 100 --no-pager
```

## Start Mount And Ongoing Sync

Enable and start the mount:

```bash
systemctl --user enable --now rclone-gdrive-mount.service
```

Enable and start the periodic sync timer:

```bash
systemctl --user enable --now rclone-documents-sync.timer
```

You can also trigger a manual sync any time:

```bash
systemctl --user start rclone-documents-sync.service
```

## Verification

Mount:

```bash
systemctl --user status rclone-gdrive-mount.service
mount | rg '/home/shri/Drive/Shri77'
ls /home/shri/Drive/Shri77
```

Timer and sync:

```bash
systemctl --user status rclone-documents-sync.timer
systemctl --user list-timers | rg rclone-documents-sync
journalctl --user -u rclone-documents-sync.service -n 100 --no-pager
```

End-to-end:

1. Create a test file in `/home/shri/Documents`
2. Run `systemctl --user start rclone-documents-sync.service`
3. Confirm the file appears in `shri77:Document`
4. Add a different test file remotely
5. Run the sync again and confirm it appears locally

## Operational Notes

- `rclone.conf` stays outside Nix at `~/.config/rclone/rclone.conf`
- the mount service does not use `--allow-other`, so no extra FUSE permission changes are required
- the mount script uses `--vfs-cache-mode writes`, `--dir-cache-time 1h`, `--poll-interval 2m`, and `--no-modtime` to reduce file-manager hangs
- the timer is set to `15m`; tighten or relax that in `modules/home-manager/rclone-gdrive.nix`
- if you want sync while logged out, enable linger for `shri`

```bash
loginctl enable-linger shri
```
