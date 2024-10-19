{pkgs, ...}: {
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      ffmpeg
      vlc
      gruvbox-factory
      ;
  };
}
