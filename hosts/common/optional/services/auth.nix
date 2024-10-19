{
  config,
  lib,
  pkgs,
  configVars,
  ...
}: let
  authelia = config.services.authelia.instances.main;
  autheliaUrl = "${authelia.settings.server.host}:${toString authelia.settings.server.port}";
  domain = configVars.domain;
in {
  environment.systemPackages = [pkgs.authelia];

  modules.redis = {
    enable = true;
    bind = "127.0.0.1";
    port = 6380;
    name = "authelia-main";
  };

  users.users.authelia-main.extraGroups = ["redis"];

  modules.traefik.services = lib.mkMerge [
    {auth.port = 9095;}
    (lib.genAttrs [
      "bazarr"
      "radarr"
      "sonarr"
      "transmission"
    ] (_: {middlewares = ["authelia"];}))
  ];

  services = {
    traefik.dynamicConfigOptions.http = {
      routers.traefik.middlewares = ["authelia"];
      middlewares.authelia.forwardAuth = {
        address = "http://${autheliaUrl}/api/verify?rd=https://auth.${domain}/";
        trustForwardHeader = true;
        authResponseHeaders = [
          "Remote-User"
          "Remote-Groups"
          "Remote-Name"
          "Remote-Email"
        ];
        tls.insecureSkipVerify = true;
      };
    };

    authelia.instances.main = {
      enable = true;
      secrets = {
        jwtSecretFile = config.sops.secrets."authelia-jwt-secret".path;
        sessionSecretFile = config.sops.secrets."authelia-session-secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia-storage-encryption-key".path;
      };
      settings = {
        theme = "dark";
        server = {
          host = "127.0.0.1";
          port = 9095;
        };
        log = {
          level = "debug";
          format = "text";
        };
        authentication_backend.file.path = config.sops.secrets."authelia-users".path;
        access_control = {
          default_policy = "deny";
          networks = [
            {
              name = "localhost";
              networks = ["127.0.0.1/32"];
            }
            {
              name = "internal";
              networks = ["10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"];
            }
          ];
          rules = [
            {
              domain = "auth.${domain}";
              policy = "bypass";
            }
            {
              domain = "bazarr.${domain}";
              policy = "bypass";
              resources = ["^/api/.*$"];
            }
            {
              domain = "*.${domain}";
              policy = "one_factor";
              subject = ["group:admin"];
            }
          ];
        };
        storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        session = {
          redis = {
            host = config.modules.redis.bind;
            port = config.modules.redis.port;
          };
          cookies = [
            {
              domain = "${domain}";
              authelia_url = "https://auth.${domain}";
            }
          ];
        };
        regulation = {
          max_retries = 5;
          find_time = "5m";
          ban_time = "15m";
        };
        notifier = {
          disable_startup_check = false;
          filesystem.filename = "/var/lib/authelia-main/notifier.txt";
        };
      };
    };
  };
}
