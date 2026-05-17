{ pkgs, ... }:
let
  mountDir = "/home/shri/Drive/Shri77";
  scriptsDir = "/home/shri/dotfiles/scripts/rclone-gdrive";
in
{
  systemd.user.services.rclone-gdrive-mount = {
    Unit = {
      Description = "Mount Shri77 Google Drive with rclone";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountDir}";
      ExecStart = "${pkgs.bash}/bin/bash ${scriptsDir}/mount-shri77-drive.sh";
      ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${mountDir}";
      Restart = "on-failure";
      RestartSec = 15;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.rclone-documents-sync = {
    Unit = {
      Description = "Sync /home/shri/Documents with shri77:Document";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${scriptsDir}/documents-sync.sh --sync";
    };
  };

  systemd.user.services.rclone-documents-resync = {
    Unit = {
      Description = "Bootstrap bisync state for /home/shri/Documents";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${scriptsDir}/documents-sync.sh --resync";
    };
  };

  systemd.user.timers.rclone-documents-sync = {
    Unit = {
      Description = "Periodic Documents bisync for shri";
    };
    Timer = {
      OnBootSec = "10m";
      OnUnitActiveSec = "15m";
      Persistent = true;
      Unit = "rclone-documents-sync.service";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
