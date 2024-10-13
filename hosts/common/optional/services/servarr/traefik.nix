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
    ddns-updater
    argon2 # Password hashing
  ];

  # Configure ddns-updater to update the DNS records for Njalla once daily
  systemd.services.ddns-updater = {
    enable = true;
    description = "DDNS Updater";
    after = ["network.target"];
    startAt = "daily";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ddns-updater}/bin/ddns-updater -c ${config.sops.secrets.ddns-updater-config.path}";
      User = "ddns-updater";
      Group = "ddns-updater";
    };
  };

  # Update firewall settings
  networking.firewall = {
    allowedTCPPorts = [80 443 8000 32400 32412]; # Add 8000 for ddns-updater WebUI, 32400 for Plex Local, 32412 for Plex External
    allowedUDPPorts = [53]; # For DNS resolution
  };

  # Create a dedicated user and group for ddns-updater
  users.users.ddns-updater = {
    isSystemUser = true;
    group = "ddns-updater";
    description = "DDNS Updater service user";
  };

  users.groups.ddns-updater = {};

  # Ensure the config file has correct permissions
  system.activationScripts = {
    ddns-updater-permissions = ''
      chmod 600 ${config.sops.secrets.ddns-updater-config.path}
    '';
  };

  # Authelia user and group
  users.users.authelia-servarr = {
    isSystemUser = true;
    group = "authelia-servarr";
  };

  users.groups.authelia-servarr = {};

  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
        };
      };
      certificatesResolvers.letsencrypt.acme = {
        email = email;
        storage = "/var/lib/traefik/acme.json";
        httpChallenge.entryPoint = "web";
        ocspStapling = true;
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
          http-catchall = {
            rule = "HostRegexp(`{host:.+}`) && PathPrefix(`/`) && !ClientIP(`192.168.0.0/16`)";
            entryPoints = ["web"];
            middlewares = ["httpsRedirect"];
            service = "noop@internal";
            priority = 1;
          };
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
            middlewares = ["authelia" "securityHeaders"];
          };
          radarr = {
            rule = "Host(`radarr.${domain}`)";
            service = "radarr";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "letsencrypt";
              options = "default";
            };
            middlewares = ["authelia" "securityHeaders"];
          };
          jellyseerr = {
            rule = "Host(`jellyseerr.${domain}`)";
            service = "jellyseerr";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "letsencrypt";
              options = "default";
            };
            middlewares = ["authelia" "securityHeaders"];
          };
          bazarr = {
            rule = "Host(`bazarr.${domain}`)";
            service = "bazarr";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "letsencrypt";
              options = "default";
            };
            middlewares = ["authelia" "securityHeaders"];
          };
          plex-local = {
            rule = "Host(`plex.${domain}`) && ClientIP(`192.168.0.0/16`, `10.0.0.0/8`, `172.16.0.0/12`)";
            service = "plex-local";
            entryPoints = ["web"];
            priority = 2;
          };
          plex-external = {
            rule = "Host(`plex.${domain}`)";
            service = "plex-external";
            entryPoints = ["websecure"];
            tls.certResolver = "letsencrypt";
            priority = 1;
            middlewares = ["securityHeaders"];
          };
          tautulli = {
            rule = "Host(`tautulli.${domain}`)";
            service = "tautulli";
            entryPoints = ["websecure"];
            tls.certResolver = "letsencrypt";
            middlewares = ["authelia" "securityHeaders"];
          };
          transmission = {
            rule = "Host(`transmission.${domain}`)";
            service = "transmission";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "letsencrypt";
              options = "default";
            };
            middlewares = ["authelia" "securityHeaders"];
          };
          ddns-updater = {
            rule = "Host(`ddns.${domain}`)";
            service = "ddns-updater";
            entryPoints = ["websecure"];
            tls.certResolver = "letsencrypt";
            middlewares = ["authelia" "securityHeaders"];
          };
        };
        services = {
          authelia.loadBalancer.servers = [{url = "http://127.0.0.1:9092";}];
          sonarr.loadBalancer.servers = [{url = "http://127.0.0.1:8989";}];
          radarr.loadBalancer.servers = [{url = "http://127.0.0.1:7878";}];
          jellyseerr.loadBalancer.servers = [{url = "http://127.0.0.1:5055";}];
          bazarr.loadBalancer.servers = [{url = "http://127.0.0.1:6767";}];
          plex-local.loadBalancer.servers = [{url = "http://127.0.0.1:32400";}];
          plex-external.loadBalancer.servers = [{url = "http://127.0.0.1:32412";}];
          tautulli.loadBalancer.servers = [{url = "http://127.0.0.1:8181";}];
          transmission.loadBalancer.servers = [{url = "http://192.168.15.1:9091";}]; # Use the WireGuard IP
          ddns-updater.loadBalancer.servers = [{url = "http://127.0.0.1:8000";}];
        };
        middlewares = {
          authelia = {
            forwardAuth = {
              address = "http://127.0.0.1:9092/api/verify?rd=https://auth.${domain}/";
              trustForwardHeader = true;
              authResponseHeaders = [
                "Remote-User"
                "Remote-Groups"
                "Remote-Name"
                "Remote-Email"
              ];
            };
          };
          securityHeaders = {
            headers = {
              stsSeconds = 31536000;
              stsIncludeSubdomains = true;
              stsPreload = true;
            };
          };
          httpsRedirect = {
            redirectScheme = {
              scheme = "https";
              permanent = true;
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
        port = 9092;
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
            domain = ["jellyseerr.${domain}"];
            policy = "one_factor";
            subject = ["group:admin" "group:basic"];
          }
          {
            domain = ["*.${domain}"];
            policy = "one_factor";
            subject = ["group:admin"];
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
    unixSocket = "/run/authelia-servarr/redis.sock";
    unixSocketPerm = 600;
  };

  # Ensure the directory exists and has correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/authelia-servarr 0700 authelia authelia - -"
    "d /var/lib/traefik 0750 traefik traefik - -"
  ];
}
