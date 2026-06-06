# disk-config.nix
#
# Layout:
#   p1 → 512M  vfat  /boot          (NixOS EFI)
#   p2 → 512M  vfat  (unmounted)    (testing EFI)
#   p3 → 405G  LUKS → LVM vg0
#          ├─ lv-root  100G  btrfs   /
#          ├─ lv-home  295G  ext4    /home
#          └─ lv-swap    5G  swap
#
# First install:   sudo nix run github:nix-community/disko -- --mode disko  --flake .#shri-nix
# Reinstall later: sudo nix run github:nix-community/disko -- --mode mount  --flake .#shri-nix
{ lib, pkgs, ... }:
let
  base     = [ "noatime" "space_cache=v2" "discard=async" ];
  data     = base ++ [ "compress=zstd:3" ];
  nixOpts  = base ++ [ "compress-force=zstd:3" ];
  logOpts  = base ++ [ "compress=zstd:9" ];
  noCow    = base ++ [ "nodatacow" ];
in
{
  disko.devices = {

    disk.main = {
      type   = "disk";
      device = "/dev/nvme0n1";

      content = {
        type = "gpt";
        partitions = {

          ESP = {
            size     = "512M";
            type     = "EF00";
            priority = 1;
            content  = {
              type         = "filesystem";
              format       = "vfat";
              mountpoint   = "/boot";
              mountOptions = [ "umask=0077" "fmask=0077" "dmask=0077" ];
            };
          };

          ESP2 = {
            size     = "512M";
            type     = "EF00";
            priority = 2;
            content  = {
              type         = "filesystem";
              format       = "vfat";
            };
          };

          crypted = {
            size     = "410G";
            priority = 3;
            content  = {
              type = "luks";
              name = "cryptroot";

              settings = {
                allowDiscards     = true;
                bypassWorkqueues  = true;
              };

              additionalKeyFiles = [];

              content = {
                type = "lvm_pv";
                vg   = "vg0";
              };
            };
          };

        };
      };
    };


    lvm_vg.vg0 = {
      type = "lvm_vg";
      lvs  = {

        lv-root = {
          size    = "100G";
          content = {
            type      = "btrfs";
            extraArgs = [ "-f" "--label" "nixos-root" ];

            subvolumes = {

              # CoW ON
              "@" = {
                mountpoint   = "/";
                mountOptions = data ++ [ "x-systemd.device-timeout=infinity" ];
              };
              "@home-btrfs" = {
                mountpoint   = "/root";
                mountOptions = data;
              };
              "@nix" = {
                mountpoint   = "/nix";
                mountOptions = nixOpts;
              };
              "@nix-store" = {
                mountpoint   = "/nix/store";
                mountOptions = nixOpts;
              };
              "@log" = {
                mountpoint   = "/var/log";
                mountOptions = logOpts;
              };
              "@cache" = {
                mountpoint   = "/var/cache";
                mountOptions = data;
              };
              "@snapshots" = {
                mountpoint   = "/.snapshots";
                mountOptions = data;
              };

              # CoW OFF
              "@docker" = {
                mountpoint   = "/var/lib/docker";
                mountOptions = noCow;
              };
              "@postgres" = {
                mountpoint   = "/var/lib/postgresql";
                mountOptions = noCow;
              };
              "@libvirt" = {
                mountpoint   = "/var/lib/libvirt/images";
                mountOptions = noCow;
              };
              "@tmp" = {
                mountpoint   = "/tmp";
                mountOptions = noCow;
              };
              "@var-tmp" = {
                mountpoint   = "/var/tmp";
                mountOptions = noCow;
              };

            };
          };
        };

        lv-home = {
          size    = "300G";
          content = {
            type         = "filesystem";
            format       = "ext4";
            mountpoint   = "/home";
            mountOptions = [ "noatime" "data=ordered" ];
            extraArgs    = [ "-L" "nixos-home" ];
          };
        };

        lv-swap = {
          size    = "5G";
          content = {
            type = "swap";
          };
        };

      };
    };

  };

  # chattr +C for nodatacow dirs
  system.activationScripts.nodatacow = {
    text = ''
      for d in \
        /var/lib/docker \
        /var/lib/postgresql \
        /var/lib/libvirt/images \
        /tmp \
        /var/tmp; do
        mkdir -p "$d"
        ${lib.getExe' pkgs.e2fsprogs "chattr"} +C "$d" 2>/dev/null || true
      done
    '';
    deps = [];
  };
}
