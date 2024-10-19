{pkgs, ...}: let
  # FIXME: That should use config options and just reference whatever is configured as the default
  browser = ["firefox.desktop"];
  editor = ["nvim.desktop"];
  media = ["vlc.desktop"];
  # Extensive list of assocations here:
  # https://github.com/iggut/GamiNiX/blob/8070528de419703e13b4d234ef39f05966a7fafb/system/desktop/home-main.nix#L77
  associations = {
    "text/*" = editor;
    "text/plain" = editor;
    "text/csv" = editor;

    # "text/html" = browser;
    "application/x-zerosize" = editor; # empty files

    "application/x-shellscript" = editor;
    "application/x-perl" = editor;
    "application/json" = editor;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;
    "application/pdf" = browser;

    "application/mxf" = media;
    "application/sdp" = media;
    "application/smil" = media;
    "application/streamingmedia" = media;
    "application/vnd.apple.mpegurl" = media;
    "application/vnd.ms-asf" = media;
    "application/vnd.rn-realmedia" = media;
    "application/vnd.rn-realmedia-vbr" = media;
    "application/x-cue" = media;
    "application/x-extension-m4a" = media;
    "application/x-extension-mp4" = media;
    "application/x-matroska" = media;
    "application/x-mpegurl" = media;
    "application/x-ogm" = media;
    "application/x-ogm-video" = media;
    "application/x-shorten" = media;
    "application/x-smil" = media;
    "application/x-streamingmedia" = media;

    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;

    "audio/*" = media;
    "video/*" = media;
    "image/*" = browser;

    "application/x-010intel" = "010editor-import.desktop";
    "application/x-010motorola" = "010editor-import.desktop";
    "application/x-010project" = "010editor-project.desktop";
    "application/x-010script" = "010editor.desktop";
    "application/x-010template" = "010editor.desktop";
    "application/x-010workspace" = "010editor-project.desktop";
  };
in {
  xdg.mime.enable = true;
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = associations;
  xdg.mimeApps.associations.added = associations;
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      handlr-regex # better xdg-open for desktop apps
      ;
  };
}
