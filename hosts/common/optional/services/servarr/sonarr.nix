{...}: let
  mediaGroup = "media";
in {
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = mediaGroup;
  };
}
