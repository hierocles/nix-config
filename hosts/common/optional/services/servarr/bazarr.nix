{...}: let
  mediaGroup = "media";
in {
  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = mediaGroup;
  };
}
