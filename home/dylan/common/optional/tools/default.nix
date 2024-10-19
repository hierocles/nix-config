{pkgs, ...}: {
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      # Development
      
      tokei
      # Device imaging
      
      rpi-imager
      # Productivity
      
      grimblast
      drawio
      libreoffice
      # Privacy
      
      _1password
      _1password-gui
      # IDEs
      
      code-cursor
      ;
  };
}
