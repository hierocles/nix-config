{mediaGroup, ...}: {
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = mediaGroup;
  };
}
