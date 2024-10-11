{
  services.plex = {
    enable = true;
    openFirewall = true;
    accelerationDevices = ["/dev/dri/renderD128"];
    group = "streamer";
  };
  services.tautulli = {
    enable = true;
    openFirewall = true;
    group = "streamer";
  };

  networking.nat = {
    forwardedPorts = [
      {
        sourcePort = 32400;
        destinationPort = 32400;
        protocol = "tcp";
      }
    ];
  };
}
