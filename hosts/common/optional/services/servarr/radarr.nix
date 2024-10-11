{...}: let
  mediaGroup = "media";
in {
  services.radarr = {
    enable = true;
    openFirewall = true;
    group = mediaGroup;
  };
}
