# NixOS Udev & Systemd Scripting Guide

This document captures the essential rules, gotchas, and debugging steps discovered when creating udev-triggered automation scripts on NixOS. Future AIs or developers should reference this when building background tasks, udev rules, or systemd services.

## 1. Udev Rules on NixOS
- **No Hardcoded Absolute Paths:** Udev rules built via NixOS `services.udev.extraRules` will fail to build if `RUN+=` points to an arbitrary path like `/home/user/script.sh`. 
- **Workaround:** If you must use `RUN+=`, wrap it in a Nix store path using `pkgs.writeShellScript`.
- **The Better Way:** Do not use `RUN+=` for anything complex. Udev blocks the event queue and will kill scripts that take too long (default 30s timeout). Instead, use `SYSTEMD_WANTS` to trigger a proper service:
  ```udev
  ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="...", TAG+="systemd", ENV{SYSTEMD_WANTS}="my-trigger.service"
  ```

## 2. Systemd Services (Triggered by Udev)
- **PATH is empty:** A systemd service triggered by udev has an extremely minimal environment. Standard commands like `bash`, `mount`, `sudo`, or `notify-send` will result in `command not found`.
- **Fix:** Explicitly declare the `path` dependencies in your `configuration.nix`:
  ```nix
  systemd.services.my-trigger = {
    description = "My Trigger";
    path = with pkgs; [ bash coreutils util-linux ]; # Add all required packages here
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/bash /path/to/script.sh --udev";
    };
  };
  ```

## 3. Bridging Root Udev to User Desktop (Wayland/DBUS/GPG)
Udev triggers as `root`. If your script needs to show notifications (`notify-send`), use the user's GPG agent (`pass`), or open a `tmux` session, it must drop privileges and inherit the user's desktop environment variables.
- **Do not use `machinectl shell`:** It can fail silently if `systemd-machined` is not enabled/running.
- **Use `runuser` + `env`:**
  ```bash
  BACKUP_USER="username"
  BACKUP_UID="1000"
  
  exec runuser -u "$BACKUP_USER" -- env \
      PATH="/run/wrappers/bin:/run/current-system/sw/bin:/etc/profiles/per-user/$BACKUP_USER/bin:/home/$BACKUP_USER/.nix-profile/bin:$PATH" \
      DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$BACKUP_UID/bus" \
      WAYLAND_DISPLAY="wayland-1" \
      XDG_RUNTIME_DIR="/run/user/$BACKUP_UID" \
      GNUPGHOME="/home/$BACKUP_USER/.gnupg" \
      /path/to/actual_script.sh
  ```
- *Note on PATH:* `/run/wrappers/bin` MUST be included and should be first so that setuid wrappers (like `sudo`) work correctly. Without it, you get `sudo must be owned by uid 0 and have the setuid bit set`.

## 4. Sudo in Background / Tmux Sessions
If a script runs detached (e.g., in `tmux new-session -d` or a background systemd service), there is no TTY to prompt for a `sudo` password. 
- You must add a `NOPASSWD` rule in `configuration.nix`.
- **Passing Environment Variables:** If your script sets an environment variable (like `BORG_PASSPHRASE`) and expects `sudo` to pass it to the target command, you MUST include the `SETENV` option in the sudo rule.
  ```nix
  security.sudo.extraRules = [{
    users = [ "username" ];
    commands = [
      { command = "/run/current-system/sw/bin/borg *"; options = [ "NOPASSWD" "SETENV" ]; }
    ];
  }];
  ```

## 5. Mounting Drives via Udev
Repeatedly plugging and unplugging a drive can leave stale mounts behind. `mountpoint -q` might say it's mounted, but trying to access it throws an `I/O Error`.
- **Fix:** Always attempt a lazy unmount before mounting fresh in your automated scripts:
  ```bash
  if mountpoint -q "/mnt/my-drive"; then
      umount -l "/mnt/my-drive" 2>/dev/null || true
      sleep 1
  fi
  mount UUID="..." "/mnt/my-drive"
  ```

## 6. Debugging Udev & Systemd
- **Monitor live udev events:** `udevadm monitor --property`
- **Check if a service triggered:** `journalctl -u my-trigger.service --no-pager`
- **Log manually from scripts:** Use `echo "message" | systemd-cat -t my-script` and read it back via `journalctl -f -t my-script`.
