{...}: let
  mediaDirectory = "/mnt/datapool";
  mediaGroup = "media";
in {
  imports = [
    ./jellyseerr.nix
    ./plex.nix
    ./prowlarr.nix
    ./bazarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./transmission.nix
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
