{config, ...}: {
  networking.wg-quick.interfaces = {
    wg0 = {
      configFile = config.sops.secrets.wireguard.path;
      postUp = [
        "ip route add 192.168.15.0/24 dev wg0" # Route only VPN traffic through WireGuard
      ];
      postDown = [
        "ip route del 192.168.15.0/24 dev wg0"
      ];
    };
  };
}
