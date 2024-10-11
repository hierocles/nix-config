{
  config,
  lib,
  pkgs,
  configVars,
  ...
}: let
  mediaDirectory = "/mnt/datapool";
  mediaGroup = "media";
  baseConfig = {
    inherit config lib pkgs configVars;
  };

  # Helper function to handle both function and set returns
  importModule = file: args: let
    imported = import file;
    result =
      if builtins.isFunction imported
      then imported (baseConfig // args)
      else imported;
  in
    lib.recursiveUpdate baseConfig result;
in {
  imports = [
    (importModule ./jellyseerr.nix {})
    (importModule ./plex.nix {})
    (importModule ./prowlarr.nix {})
    (importModule ./bazarr.nix {inherit mediaGroup;})
    (importModule ./radarr.nix {inherit mediaGroup;})
    (importModule ./sonarr.nix {inherit mediaGroup;})
    (importModule ./transmission.nix {inherit mediaDirectory;})
  ];

  users.groups = {
    streamer = {};
    torrenter = {};
    ${mediaGroup} = {
      members = [
        "radarr"
        "sonarr"
        "bazarr"
        "plex"
        "tautulli"
      ];
    };
  };

  users.users = {
    streamer = {
      isSystemUser = true;
      group = "streamer";
    };
    torrenter = {
      isSystemUser = true;
      group = "torrenter";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${mediaDirectory} 0775 root ${mediaGroup} -"
    "d ${mediaDirectory}/library/movies 0755 streamer ${mediaGroup} -"
    "d ${mediaDirectory}/library/tv 0755 streamer ${mediaGroup} -"
    "d ${mediaDirectory}/torrents 0755 torrenter ${mediaGroup} -"
    "d ${mediaDirectory}/torrents/.incomplete 0755 torrenter ${mediaGroup} -"
    "d ${mediaDirectory}/torrents/.watch 0755 torrenter ${mediaGroup} -"
    "d ${mediaDirectory}/torrents/radarr 0755 torrenter ${mediaGroup} -"
    "d ${mediaDirectory}/torrents/sonarr 0755 torrenter ${mediaGroup} -"
    "d ${mediaDirectory}/torrents/bazarr 0755 torrenter ${mediaGroup} -"
  ];
}
