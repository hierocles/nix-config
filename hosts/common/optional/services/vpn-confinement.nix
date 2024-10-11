{
  config,
  configVars,
  ...
}: {
  vpnNamespaces.wg = {
    enable = true;
    wireguardConfigFile = config.sops.secrets.wireguard.path;
    accessibleFrom = [
      "192.168.1.0/24"
      "10.0.0.0/8"
      "127.0.0.1"
    ];
    openVPNPorts = [
      {
        port = configVars.wireguard.vpnPort;
        protocol = "both";
      }
    ];
  };
}
