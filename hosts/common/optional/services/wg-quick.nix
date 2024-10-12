{
  config,
  lib,
  ...
}: {
  networking.wg-quick.interfaces = {
    wg0 = {
      configFile = config.sops.secrets.wireguard.path;
      autostart = true;
    };
  };

  # Ensure wg-quick service is enabled
  systemd.services.wg-quick-wg0 = {
    enable = true;
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };

  # Configure firewall to allow WireGuard traffic
  networking.firewall = {
    allowedUDPPorts = [1637];
    trustedInterfaces = ["wg0"];
  };
}
