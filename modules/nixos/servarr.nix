{
  config,
  lib,
  ...
}: let
  cfg = config.modules.servarr;
in {
  options.modules.servarr = with lib; {
    enable = mkEnableOption (mdDoc "Media server stack with Plex, Sonarr, Radarr, Bazarr, Prowlarr, and optionally Tautulli and Jellyseerr");

    mediaGroup = mkOption {
      type = types.str;
      default = "media";
      description = mdDoc "Group for media related files";
    };

    mediaDir = mkOption {
      type = types.str;
      default = "/mnt/media";
      description = mdDoc "Directory for media related files";
    };

    jellyseerr = {
      enable = mkEnableOption (mdDoc "Jellyseerr");
      port = mkOption {
        type = types.port;
        default = 5055;
        description = mdDoc "Port for Jellyseerr";
      };
    };

    tautulli = {
      enable = mkEnableOption (mdDoc "Tautulli");
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "Whether to open firewall ports for all enabled services";
    };
  };

  config = with lib;
    mkIf cfg.enable {
      users = {
        groups.${cfg.mediaGroup} = {};
        users = {
          streamer = {
            isSystemUser = true;
            group = cfg.mediaGroup;
            description = "User for streaming services";
          };
          torrenter = {
            isSystemUser = true;
            group = cfg.mediaGroup;
            description = "User for torrent services";
          };
        };
      };

      systemd.tmpfiles.settings = {
        "10-media" = {
          "${cfg.mediaDir}".d = {
            group = cfg.mediaGroup;
            mode = "0775";
            user = "-";
          };
          "${cfg.mediaDir}/library/movies".d = {
            group = cfg.mediaGroup;
            mode = "0775";
            user = "streamer";
          };
          "${cfg.mediaDir}/library/shows".d = {
            group = cfg.mediaGroup;
            mode = "0775";
            user = "streamer";
          };
          "${cfg.mediaDir}/torrents".d = {
            group = cfg.mediaGroup;
            mode = "0775";
            user = "torrenter";
          };
          "${cfg.mediaDir}/torrents/.incomplete".d = {
            group = cfg.mediaGroup;
            mode = "0775";
            user = "torrenter";
          };
          "${cfg.mediaDir}/torrents/.watch".d = {
            group = cfg.mediaGroup;
            mode = "0775";
            user = "torrenter";
          };
          "${cfg.mediaDir}/torrents/radarr".d = {
            group = cfg.mediaGroup;
            mode = "0775";
            user = "torrenter";
          };
          "${cfg.mediaDir}/torrents/sonarr".d = {
            group = cfg.mediaGroup;
            mode = "0775";
            user = "torrenter";
          };
        };
      };
      services = {
        plex = {
          enable = true;
          user = "streamer";
          group = cfg.mediaGroup;
          openFirewall = cfg.openFirewall;
        };

        tautulli = mkIf cfg.tautulli.enable {
          enable = true;
          openFirewall = cfg.openFirewall;
        };

        sonarr = {
          enable = true;
          group = cfg.mediaGroup;
          openFirewall = cfg.openFirewall;
        };

        radarr = {
          enable = true;
          group = cfg.mediaGroup;
          openFirewall = cfg.openFirewall;
        };

        bazarr = {
          enable = true;
          group = cfg.mediaGroup;
          openFirewall = cfg.openFirewall;
        };

        prowlarr = {
          enable = true;
          openFirewall = cfg.openFirewall;
        };

        jellyseerr = mkIf cfg.jellyseerr.enable {
          enable = true;
          port = cfg.jellyseerr.port;
          openFirewall = cfg.openFirewall;
        };
      };

      networking.firewall = mkIf cfg.openFirewall {
        allowedTCPPorts =
          [
            32400 # Plex
            8989 # Sonarr
            7878 # Radarr
            6767 # Bazarr
            9696 # Prowlarr
          ]
          ++ optional cfg.tautulli.enable 8181
          ++ optional cfg.jellyseerr.enable cfg.jellyseerr.port;
      };
    };
}
