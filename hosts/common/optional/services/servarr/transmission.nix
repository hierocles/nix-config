{
  pkgs,
  config,
  mediaDirectory,
  configVars,
  ...
}: {
  config.sops.secrets.transmission = {
    owner = config.services.transmission.user;
    group = config.services.transmission.group;
    mode = "0400";
  };
  systemd.services.transmission.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };
  vpnNamespaces.wg = {
    portMappings = [
      {
        from = 9091;
        to = 9091;
      }
    ];
  };

  services.transmission = {
    enable = true;
    user = "torrenter";
    package = pkgs.transmission_4;
    group = "torrenter";
    openRPCPort = true;
    openPeerPorts = true;
    settings = {
      peer-port = configVars.wireguard.vpnPort;
      download-dir = "${mediaDirectory}/torrents";
      incomplete-dir-enabled = true;
      incomplete-dir = "${mediaDirectory}/torrents/.incomplete";
      watch-dir-enabled = true;
      watch-dir = "${mediaDirectory}/torrents/.watch";
      rpc-port = 9091;
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.1";
      rpc-bind-address = "192.168.15.1"; # vpnConfinement
      rpc-authentication-required = true;
      rpc-authentication-file = config.sops.secrets.transmission.path;
      blocklist-enabled = true;
      blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";
      utp-enabled = true;
      encryption = 1;
      port-forwarding-enabled = true;
      download-queue-size = 10;
      ratio-limit-enabled = true;
      ratio-limit = 1;
    };
  };
  systemd.services.transmission.serviceConfig.IOSchedulingPriority = 7;
}
