{
  config,
  pkgs,
  configVars,
  ...
}: {
  networking.firewall.allowedUDPPorts = [
    configVars.networking.wireguard.port
  ];

  modules = {
    ddns-updater = {
      enable = true;
      configFile = config.sops.secrets.ddns-updater-config.path;
    };

    servarr = {
      enable = true;
      mediaDir = "/mnt/media";
      mediaGroup = "media";
      jellyseerr.enable = true;
      tautulli.enable = true;
      openFirewall = true;
    };

    traefik = {
      enable = true;
      domain = configVars.domain;
      njallaTLS = {
        enable = true;
        email = configVars.email.user;
        tokenFile = config.sops.secrets.njalla-token.path;
      };
      services = {
        plex = {port = 32400;};
        tautulli = {port = 8181;};
        sonarr = {port = 8989;};
        radarr = {port = 7878;};
        prowlarr = {port = 9696;};
        bazarr = {port = 6767;};
        transmission = {
          host = "192.168.15.1"; # vpnConfinement namespace address
          port = 9091;
        };
        jellyseerr = {port = 5055;};
      };
    };

    cross-seed = {
      enable = true;
      user = "torrenter";
      group = config.modules.servarr.mediaGroup;
      settings = {
        dataDirs = [
          "${config.modules.servarr.mediaDir}/library/movies"
          "${config.modules.servarr.mediaDir}/library/shows"
        ];
        torrentDir = "${config.modules.servarr.mediaDir}/torrents";
        outputDir = "${config.modules.servarr.mediaDir}/.watch";
        transmissionRpcUrl = "http://192.168.15.1:9091/transmission/rpc";
      };
    };
  };

  services.transmission = {
    enable = true;
    group = config.modules.servarr.mediaGroup;
    package = pkgs.transmission_4;
    user = "torrenter";
    openPeerPorts = true;
    openRPCPort = true;
    settings = {
      download-dir = "${config.modules.servarr.mediaDir}/torrents";
      incomplete-dir = "${config.modules.servarr.mediaDir}/torrents/.incomplete";
      incomplete-dir-enabled = true;
      watch-dir = "${config.modules.servarr.mediaDir}/torrents/.watch";
      trash-original-torrent-files = false;
      watch-dir-enabled = true;
      peer-port = configVars.networking.wireguard.port;
      rpc-bind-address = "192.168.15.1"; # vpnConfinement namespace address
      rpc-port = 9091;
      rpc-whitelist = "192.168.*.*,127.0.0.1";
      rpc-host-whitelist = "transmission.${configVars.domain}";
      rpc-host-whitelist-enabled = true;
      blocklist-enabled = true;
      blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";
    };
  };

  # Uncomment and update when compatible with latest Selenium version
  # services.flaresolverr = {
  #   enable = true;
  #   port = 8191;
  #   openFirewall = true;
  # };
}
