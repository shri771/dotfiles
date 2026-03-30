{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Just a shortcut to our custom options
  cfg = config.services.my-vaultwarden;
in
{
  # 1. Define the option to enable/disable it
  options.services.my-vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden OCI Container with Caddy Proxy";
  };

  # 2. Apply ALL configuration only if 'enable' is true
  config = lib.mkIf cfg.enable {

    # --- CADDY & FIREWALL CONFIGURATION ---
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    services.caddy = {
      enable = true;
      # IMPORTANT: Change this to the IP address of your NixOS machine
      virtualHosts."shri-nix, shri-nix.local" = {
        extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:8080
        '';
      };
    };

    # --- VAULTWARDEN CONTAINER CONFIGURATION ---
    virtualisation.oci-containers = {
      backend = "docker";

      containers.vaultwarden = {
        image = "vaultwarden/server:latest";
        autoStart = true;

        ports = [
          "127.0.0.1:8080:80"
        ];

        environment = {
          SIGNUPS_ALLOWED = "false";
          LOG_LEVEL = "info";
          WEBSOCKET_ENABLED = "true";
          DATABASE_URL = "data/db.sqlite3";
          RUST_BACKTRACE = "1";
          ARGON2_MEMORY = "65536";
          ARGON2_ITERATIONS = "3";
          ARGON2_PARALLELISM = "4";
          HASHING_SECRET_FILE = "/run/secrets/hashing_secret";
          LOG_FILE = "/data/vaultwarden.log";
        };

        volumes = [
          "/home/shri/Docker/Con/Vaultwarden/bw-data:/data"
          "/home/shri/Docker/Con/Vaultwarden/secrets/HASHING_SECRET.txt:/run/secrets/hashing_secret:ro"
        ];

        extraOptions = [
          "--read-only"
          "--tmpfs=/tmp"
          "--tmpfs=/run"
          "--tmpfs=/var/log"
        ];
      };
    };
  };
}
