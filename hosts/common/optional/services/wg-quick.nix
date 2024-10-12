{config, ...}: {
  networking.wg-quick.interfaces = {
    wg0 = {
      configFile = config.sops.secrets.wireguard.path;
      postUp = [
        "ip route add 10.0.0.0/8 dev wg0" # Route only VPN traffic through WireGuard
      ];
      postDown = [
        "ip route del 10.0.0.0/8 dev wg0"
      ];
    };
  };
}
