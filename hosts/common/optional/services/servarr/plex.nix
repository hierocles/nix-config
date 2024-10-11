{configVars, ...}: {
  services.plex = {
    enable = true;
    openFirewall = true;
    accelerationDevices = ["/dev/dri/renderD128"];
    user = "streamer";
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
        destination = configVars.networking.nat.plex.destination;
        proto = configVars.networking.nat.plex.protocol;
      }
    ];
  };
}
