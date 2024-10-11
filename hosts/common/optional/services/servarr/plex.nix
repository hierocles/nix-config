{configVars, ...}: {
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
    forwardPorts = [
      {
        sourcePort = configVars.networking.nat.plex.sourcePort;
        destinationPort = configVars.networking.nat.plex.destinationPort;
        protocol = configVars.networking.nat.plex.protocol;
      }
    ];
  };
}
