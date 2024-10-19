{
  config,
  lib,
  ...
}: let
  cfg = config.modules.traefik;
  hasTLS = cfg.njallaTLS.enable;

  serviceOptions = _:
    with lib; {
      options = {
        domain = mkOption {
          type = types.str;
        };
        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
        };
        port = mkOption {
          type = types.port;
        };
        middlewares = mkOption {
          type = types.listOf types.str;
          default = [];
        };
      };
    };
  mkService = name: value: {
    loadBalancer = {
      servers = [
        {url = "http://${value.host}:${builtins.toString value.port}";}
      ];
    };
  };
  mkRouter = name: value: {
    rule = "Host(`${name}.${cfg.domain}`)";
    service = name;
    entrypoints = [cfg.entrypoint];
    middlewares = value.middlewares;
  };
in {
  options.modules.traefik = with lib; {
    enable = mkEnableOption "traefik";
    services = mkOption {
      type = types.attrsOf (types.submodule serviceOptions);
      default = {};
    };
    njallaTLS = {
      enable = mkEnableOption "njalla TLS";
      email = mkOption {
        type = types.str;
      };
      tokenFile = mkOption {
        type = types.str;
      };
    };
    entrypoint = mkOption {
      default =
        if hasTLS
        then "websecure"
        else "web";
      readOnly = true;
    };
    domain = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.njallaTLS.enable -> cfg.njallaTLS.email != "";
          message = "Email is required for ACME TLS certificates";
        }
        {
          assertion = cfg.njallaTLS.enable -> cfg.njallaTLS.tokenFile != "";
          message = "Njalla token file is required for DDNS updates";
        }
        {
          assertion = cfg.domain != "";
          message = "Domain is required for Traefik";
        }
      ];
      networking.firewall.allowedTCPPorts = [80] ++ lib.lists.optional hasTLS 443;
      systemd.services.traefik.environment = lib.mkIf hasTLS {
        NJALLA_TOKEN_FILE = cfg.njallaTLS.tokenFile;
      };

      services.traefik = {
        enable = true;
        staticConfigOptions = lib.mkMerge [
          {
            log.level = "DEBUG";
            entryPoints.web.address = ":80";
            api.dashboard = true;
            global = {
              checknewversion = false;
              sendanonymoususage = false;
            };
          }
          (lib.mkIf hasTLS {
            entryPoints = {
              web = {
                http.redirections.entryPoint = {
                  to = "websecure";
                  scheme = "https";
                };
              };
              websecure = {
                address = ":443";
                http.tls = {
                  certResolver = "letsencrypt";
                  domains = [
                    {
                      main = "${cfg.domain}";
                      sans = ["*.${cfg.domain}"];
                    }
                  ];
                };
              };
            };
            certificatesResolvers = {
              letsencrypt = {
                acme = {
                  email = cfg.njallaTLS.email;
                  storage = "${config.services.traefik.dataDir}/acme.json";
                  dnsChallenge = {
                    provider = "njalla";
                    delayBeforeCheck = 30;
                  };
                };
              };
            };
          })
        ];
        dynamicConfigOptions = {
          http = {
            routers = lib.mkMerge [
              (builtins.mapAttrs mkRouter cfg.services)
              {
                traefik = {
                  rule = "Host(`traefik.${cfg.domain}`)";
                  service = "api@internal";
                  entrypoints = [cfg.entrypoint];
                };
              }
            ];
            services = builtins.mapAttrs mkService cfg.services;
          };
        };
      };
    }
  ]);
}
