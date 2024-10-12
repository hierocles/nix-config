{...}: {
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

  users.users.streamer.extraGroups = ["video" "render"];
}
