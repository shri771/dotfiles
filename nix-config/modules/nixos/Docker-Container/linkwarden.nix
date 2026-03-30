{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.my-linkwarden;
in
{
  options.services.my-linkwarden = {
    enable = lib.mkEnableOption "Linkwarden multi-container setup with Caddy";
  };

  config = lib.mkIf cfg.enable {

    # 1. CADDY PROXY (Merges seamlessly with your Vaultwarden Caddy config)
    services.caddy = {
      enable = true;
      virtualHosts."linkwarden, links.shri-nix.local" = {
        extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:3000
        '';
      };
    };

    # 2. CREATE DOCKER NETWORK
    # NixOS doesn't auto-create networks like Compose, so we do it via systemd
    systemd.services.create-linkwarden-network = {
      description = "Create Docker network for Linkwarden";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.docker}/bin/docker network inspect linkwarden_net >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create linkwarden_net
      '';
    };

    # 3. THE CONTAINERS
    virtualisation.oci-containers = {
      backend = "docker";

      containers = {

        # --- Postgres Database ---
        postgres = {
          image = "postgres:16-alpine";
          autoStart = true;
          environmentFiles = [ "/home/shri/linkwarden/.env" ];
          volumes = [
            "/home/shri/linkwarden/pgdata:/var/lib/postgresql/data"
          ];
          extraOptions = [ "--network=linkwarden_net" ];
          # Ensure network exists before starting
          dependsOn = [ "create-linkwarden-network" ];
        };

        # --- Meilisearch ---
        meilisearch = {
          image = "getmeili/meilisearch:v1.12.8";
          autoStart = true;
          environmentFiles = [ "/home/shri/linkwarden/.env" ];
          volumes = [
            "/home/shri/linkwarden/meili_data:/meili_data"
          ];
          extraOptions = [ "--network=linkwarden_net" ];
          dependsOn = [ "create-linkwarden-network" ];
        };

        # --- Linkwarden App ---
        linkwarden = {
          image = "ghcr.io/linkwarden/linkwarden:latest";
          autoStart = true;
          environmentFiles = [ "/home/shri/linkwarden/.env" ];
          ports = [
            "127.0.0.1:3000:3000"
          ];
          volumes = [
            "/home/shri/linkwarden/data:/data/data"
          ];
          extraOptions = [ "--network=linkwarden_net" ];
          # Ensure DB and Search are up before the app starts
          dependsOn = [
            "postgres"
            "meilisearch"
          ];
        };

      };
    };
  };
}
