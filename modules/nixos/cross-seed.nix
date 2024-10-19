# https://github.com/NixOS/nixpkgs/issues/289917#issuecomment-2227298444
{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.cross-seed;

  configFileContent = builtins.toJSON cfg.settings;
  configFile = pkgs.writeText "config.js" ''
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    module.exports = ${configFileContent};
  '';

  cross-seed = with pkgs;
    buildNpmPackage rec {
      pname = "cross-seed";
      version = "5.9.1";

      src = fetchFromGitHub {
        owner = "cross-seed";
        repo = "cross-seed";
        rev = "refs/tags/v${version}";
        hash = "sha256-kxJafaU4Ih6zUwy2xjjLBro/MQ6M0rtp7Imx+Ut3CYs=";
      };
      npmDepsHash = "sha256-vexAGEhgBUb42ReWORaf0MqLQ2Txz0nl4eJ5f34Tm68=";
    };
in {
  options.modules.cross-seed = {
    enable = mkEnableOption "Cross Seed service";

    home = mkOption {
      type = types.path;
      default = "/var/lib/cross-seed";
    };

    user = mkOption {
      type = types.str;
      default = "cross-seed";
      description = lib.mdDoc "User account under which cross-seed runs.";
    };

    group = mkOption {
      type = types.str;
      default = "cross-seed";
      description = lib.mdDoc "Group account under which cross-seed runs.";
    };

    settings = mkOption {
      default = {};
      type = types.submodule {
        freeformType = (pkgs.formats.json {}).type;
        options = {
          delay = mkOption {
            type = types.int;
            default = 10;
            description = "Pause at least this much in between each search. Higher is safer.";
          };

          torznab = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of Torznab URLs.";
          };

          dataDirs = mkOption {
            type = types.nullOr (types.listOf types.path);
            default = null;
            description = "Directories to your downloaded torrent data.";
          };

          matchMode = mkOption {
            type = types.enum ["safe" "risky"];
            default = "safe";
            description = "Determines flexibility of naming during matching.";
          };

          dataCategory = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Defines what category torrents injected by data-based matching should use.";
          };

          linkDir = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Directory for creating links to scanned files.";
          };

          linkType = mkOption {
            type = types.enum ["symlink" "hardlink"];
            default = "symlink";
            description = "Type of links to use for data-based matches.";
          };

          skipRecheck = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to skip recheck in Qbittorrent.";
          };

          maxDataDepth = mkOption {
            type = types.int;
            default = 2;
            description = "Determines how deep into the specified dataDirs to go to generate new searchees.";
          };

          torrentDir = mkOption {
            type = types.str;
            default = "/path/to/torrent/file/dir";
            description = "Directory containing .torrent files.";
          };

          outputDir = mkOption {
            type = types.str;
            default = ".";
            description = "Where to put the torrent files that cross-seed finds for you.";
          };

          includeEpisodes = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to search for all episode torrents, including those from season packs.";
          };

          includeSingleEpisodes = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to include single episode torrents in the search.";
          };

          includeNonVideos = mkOption {
            type = types.bool;
            default = false;
            description = "Include torrents which contain non-video files.";
          };

          fuzzySizeThreshold = mkOption {
            type = types.float;
            default = 0.02;
            description = "Fuzzy size match threshold as a decimal value.";
          };

          excludeOlder = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Exclude torrents first seen more than this long ago.";
          };

          excludeRecentSearch = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Exclude torrents which have been searched more recently than this.";
          };

          action = mkOption {
            type = types.enum ["save" "inject"];
            default = "save";
            description = "With 'inject' you need to set up one of the specified clients.";
          };

          rtorrentRpcUrl = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL of your rtorrent XMLRPC interface.";
          };

          qbittorrentUrl = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL of your qBittorrent webui.";
          };

          transmissionRpcUrl = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL of your Transmission RPC interface.";
          };

          delugeRpcUrl = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL of your Deluge JSON-RPC interface.";
          };

          duplicateCategories = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to inject using the same labels/categories as the original torrent.";
          };

          notificationWebhookUrl = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "URL for POST requests with JSON payload of { title, body }.";
          };

          port = mkOption {
            type = types.int;
            default = 2468;
            description = "Listen on a custom port.";
          };

          host = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Bind to a specific host address.";
          };

          apiAuth = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to require authentication for API.";
          };

          rssCadence = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Run RSS scans on a schedule.";
          };

          searchCadence = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Run searches on a schedule.";
          };

          snatchTimeout = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Fail snatch requests that haven't responded after this long.";
          };

          searchTimeout = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Fail search requests that haven't responded after this long.";
          };

          searchLimit = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "The number of searches to be done before it stops.";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cross-seed = {
      enable = true;
      description = "cross-seed daemon";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      requires = ["transmission.service"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Environment = "CONFIG_DIR=${cfg.home}";
        ExecStart = "${cross-seed}/bin/cross-seed daemon";
        Restart = "always";
        Type = "simple";

        ExecStartPre = [
          ("+"
            + pkgs.writeShellScript "cross-seed-prestart" ''
              set -eu
              install -D -m 600 -o '${cfg.user}' -g '${cfg.group}' \
                '${configFile}' '${cfg.home}/config.js'
            '')
        ];
      };
    };

    users.users = mkIf (cfg.user == "cross-seed") {
      cross-seed = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = mkIf (cfg.group == "cross-seed") {
      cross-seed = {};
    };
  };
}
