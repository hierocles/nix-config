{mediaGroup, ...}: {
  services.radarr = {
    enable = true;
    openFirewall = true;
    group = mediaGroup;
  };
}
