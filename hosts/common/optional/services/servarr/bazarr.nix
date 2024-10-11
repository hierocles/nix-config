{mediaGroup, ...}: {
  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = mediaGroup;
  };
}
