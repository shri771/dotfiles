{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.my-linkwarden;
  # --- WE DEFINE THE PASSWORD ONCE HERE ---
  dbPassword = "shriLinkwarden2026";
in
{
  options.services.my-linkwarden = {
    enable = lib.mkEnableOption "Linkwarden multi-container setup with Caddy";
  };

  config = lib.mkIf cfg.enable {

    networking.extraHosts = ''
      127.0.0.1 linkwarden
    '';

    services.caddy = {
      enable = true;
      virtualHosts."linkwarden, links.shri-nix.local" = {
        extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:3000
        '';
      };
    };

    systemd.services.create-linkwarden-network = {
      description = "Create Docker network for Linkwarden";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.docker}/bin/docker network inspect linkwarden_net >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create linkwarden_net
      '';
    };

    virtualisation.oci-containers = {
      backend = "docker";
      containers = {

        postgres = {
          image = "postgres:16-alpine";
          autoStart = true;
          environment = {
            POSTGRES_PASSWORD = "${dbPassword}";
            POSTGRES_USER = "postgres";
            POSTGRES_DB = "postgres";
          };
          volumes = [ "/home/shri/linkwarden/pgdata:/var/lib/postgresql/data" ];
          extraOptions = [ "--network=linkwarden_net" ];
        };

        meilisearch = {
          image = "getmeili/meilisearch:v1.12.8";
          autoStart = true;
          environmentFiles = [ "/home/shri/linkwarden/.env" ];
          volumes = [ "/home/shri/linkwarden/meili_data:/meili_data" ];
          extraOptions = [ "--network=linkwarden_net" ];
        };

        linkwarden = {
          image = "ghcr.io/linkwarden/linkwarden:latest";
          autoStart = true;
          environmentFiles = [ "/home/shri/linkwarden/.env" ];
          environment = {
            DATABASE_URL = "postgresql://postgres:${dbPassword}@postgres:5432/postgres";
          };
          ports = [ "127.0.0.1:3000:3000" ];
          volumes = [ "/home/shri/linkwarden/data:/data/data" ];
          dependsOn = [
            "postgres"
            "meilisearch"
          ];
          extraOptions = [ "--network=linkwarden_net" ];
        };

      };
    };

    systemd.services.docker-postgres = {
      requires = [ "create-linkwarden-network.service" ];
      after = [ "create-linkwarden-network.service" ];
    };
    systemd.services.docker-meilisearch = {
      requires = [ "create-linkwarden-network.service" ];
      after = [ "create-linkwarden-network.service" ];
    };
    systemd.services.docker-linkwarden = {
      requires = [ "create-linkwarden-network.service" ];
      after = [ "create-linkwarden-network.service" ];
    };

  };
}
