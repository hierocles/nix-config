{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.wireguard.enable = true;
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
    preStart = ''
      ${pkgs.iproute2}/bin/ip link delete dev wg0 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip route del 192.168.15.0/24 2>/dev/null || true
    '';
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # Configure firewall to allow WireGuard traffic
  networking.firewall = {
    allowedUDPPorts = [1637];
    trustedInterfaces = ["wg0"];
  };

  # Enable IP forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = lib.mkOverride 99 1;
  };

  # Clean up any old WireGuard configurations
  systemd.services.cleanup-wireguard = {
    description = "Clean up old WireGuard configurations";
    wantedBy = ["multi-user.target"];
    before = ["wg-quick-wg0.service"];
    script = ''
      ${pkgs.iproute2}/bin/ip link delete wg-br 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip link delete veth-wg-br 2>/dev/null || true
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT 2>/dev/null || true
      ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT 2>/dev/null || true
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE 2>/dev/null || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Add a custom service to manage WireGuard routes
  systemd.services.wireguard-routes = {
    description = "Manage WireGuard routes";
    after = ["wg-quick-wg0.service"];
    wantedBy = ["multi-user.target"];
    script = ''
      # Wait for wg0 interface to be up
      while ! ${pkgs.iproute2}/bin/ip link show wg0 >/dev/null 2>&1; do
        sleep 1
      done

      # Add routes
      ${pkgs.iproute2}/bin/ip route add 192.168.15.0/24 dev wg0 || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
