{config, ...}: {
  vpnNamespaces.airvpn = {
    enable = true;
    wireguardConfigFile = config.sops.secrets.wg_quick.path;
    accessibleFrom = [
      "192.168.1.0/24"
      "127.0.0.1/32"
    ];
    portMappings = [
      {
        from = 9091; # Transmission
        to = 9091;
        protocol = "tcp";
      }
    ];
    openVPNPorts = [
      {
        port = 6360;
        protocol = "both";
      }
      {
        port = 80;
        protocol = "tcp";
      }
      {
        port = 443;
        protocol = "tcp";
      }
    ];
  };

  # Define services that should be confined to the VPN
  systemd.services.transmission.vpnConfinement = {
    enable = true;
    vpnNamespace = "airvpn";
  };
}
