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
      28880
      28843
    ];
    services.caddy = {
      enable = true;
      # Disable the automatic HTTP->HTTPS redirect so Caddy stops binding port 80.
      # (tls internal needs no ACME HTTP-01 challenge, so port 80 isn't required.)
      globalConfig = ''
        auto_https disable_redirects
      '';
      # IMPORTANT: Change this to the IP address of your NixOS machine
      virtualHosts."shri-nix:28880, shri-nix.local:28843" = {
        extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:28881
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
          "127.0.0.1:28881:28881"
        ];

        environment = {
          # Move Vaultwarden's internal listener off the default port 80.
          ROCKET_PORT = "28881";
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
