{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    flaresolverr
  ];

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
}
