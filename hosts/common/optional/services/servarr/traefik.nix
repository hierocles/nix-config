#TODO: Add traefik service that proxies to all the arr services
{
  config,
  configVars,
  pkgs,
  ...
}: let
  domain = configVars.domain;
  email = configVars.email.user;
in {
  # Add SQLite to system packages
  environment.systemPackages = with pkgs; [
    sqlite
  ];

  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";
        };
      };
      certificatesResolvers.letsencrypt.acme = {
        email = email;
        storage = "/var/lib/traefik/acme.json";
        httpChallenge.entryPoint = "web";
      };
      tls = {
        options = {
          default = {
            minVersion = "VersionTLS12";
            sniStrict = true;
            cipherSuites = [
              "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
              "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
              "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
              "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
              "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305"
              "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
            ];
          };
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          authelia = {
            rule = "Host(`auth.${domain}``)";
            service = "authelia";
            entryPoints = ["websecure"];
            tls.certResolver = "letsencrypt";
          };
          sonarr = {
            rule = "Host(`sonarr.${domain}`)";
            service = "sonarr";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "letsencrypt";
              options = "default";
            };
            middlewares = ["authelia"];
          };
          radarr = {
            rule = "Host(`radarr.${domain}`)";
            service = "radarr";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "letsencrypt";
              options = "default";
            };
            middlewares = ["authelia"];
          };
          jellyseerr = {
            rule = "Host(`jellyseerr.${domain}`)";
            service = "jellyseerr";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "letsencrypt";
              options = "default";
            };
            middlewares = ["authelia"];
          };
          bazarr = {
            rule = "Host(`bazarr.${domain}`)";
            service = "bazarr";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "letsencrypt";
              options = "default";
            };
            middlewares = ["authelia"];
          };
          plex = {
            rule = "Host(`plex.${domain}`)";
            service = "plex";
            entryPoints = ["websecure"];
            tls.certResolver = "letsencrypt";
            middlewares = ["plex-auth"];
          };
          tautulli = {
            rule = "Host(`tautulli.${domain}`)";
            service = "tautulli";
            entryPoints = ["websecure"];
            tls.certResolver = "letsencrypt";
            middlewares = ["authelia"];
          };
        };
        services = {
          authelia.loadBalancer.servers = [{url = "http://127.0.0.1:9091";}];
          sonarr.loadBalancer.servers = [{url = "http://127.0.0.1:8989";}];
          radarr.loadBalancer.servers = [{url = "http://127.0.0.1:7878";}];
          jellyseerr.loadBalancer.servers = [{url = "http://127.0.0.1:5055";}];
          bazarr.loadBalancer.servers = [{url = "http://127.0.0.1:6767";}];
          plex.loadBalancer.servers = [{url = "http://127.0.0.1:32400";}];
          tautulli.loadBalancer.servers = [{url = "http://127.0.0.1:8181";}];
        };
        middlewares = {
          authelia = {
            forwardAuth = {
              address = "http://127.0.0.1:9091/api/verify?rd=https://auth.${domain}/";
              trustForwardHeader = true;
              authResponseHeaders = [
                "Remote-User"
                "Remote-Groups"
                "Remote-Name"
                "Remote-Email"
              ];
            };
          };
          plex-auth = {
            chain = {
              middlewares = ["plex-whitelist" "authelia"];
            };
          };
          plex-whitelist = {
            plugin = {
              rewritebody = {
                rewrites = [
                  {
                    regex = "^(?:(?!/web|/:/websockets/notifications).)";
                    replacement = "";
                  }
                ];
              };
            };
          };
        };
      };
    };
  };

  services.authelia.instances.servarr = {
    name = "authelia-servarr";
    secrets = {
      jwtSecretFile = config.sops.secrets.authelia-jwt-secret.path;
      sessionSecretFile = config.sops.secrets.authelia-session-secret.path;
      storageEncryptionKeyFile = config.sops.secrets.authelia-storage-encryption-key.path;
    };
    settings = {
      theme = "dark";
      default_redirection_url = "https://${domain}/";
      server = {
        host = "127.0.0.1";
        port = 9091;
      };
      log = {
        level = "info";
        format = "text";
      };
      authentication_backend = {
        file = {
          path = config.sops.secrets.authelia-users.path;
        };
      };
      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = ["auth.${domain}"];
            policy = "bypass";
          }
          {
            domain = ["*.${domain}"];
            policy = "one_factor";
          }
        ];
      };
      session = {
        name = "authelia_session";
        expiration = "12h";
        inactivity = "30m";
        domain = domain;
        redis = {
          host = "/run/authelia-servarr/redis.sock";
        };
        same_site = "lax";
        remember_me_duration = "1M";
      };
      regulation = {
        max_retries = 5;
        find_time = "5m";
        ban_time = "15m";
      };
      storage = {
        local = {
          path = "/var/lib/authelia-servarr/db.sqlite3";
        };
      };
      notifier = {
        disable_startup_check = false;
        filesystem = {
          filename = "/var/lib/authelia-servarr/notifier.txt";
        };
      };
    };
  };
  services.redis.servers.authelia-servarr = {
    enable = true;
    user = "authelia-servarr";
    unixSocket = "/run/authelia/redis.sock";
    unixSocketPerm = 600;
  };

  # Ensure the directory exists and has correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/authelia-servarr 0700 authelia authelia - -"
    "d /var/lib/traefik 0750 traefik traefik - -"
  ];
}
