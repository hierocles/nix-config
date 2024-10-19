{pkgs, ...}: {
  imports = [
    # Packages with custom configs go here

    ./hyprland

    ########## Utilities ##########
    ./services/dunst.nix # Notification daemon
    ./waybar.nix # infobar
    ./rofi.nix
    ./networkmanager.nix
  ];
  home.packages = [
    pkgs.pavucontrol # gui for pulseaudio server and volume controls
    pkgs.wl-clipboard # wayland copy and paste
    pkgs.galculator # gtk based calculator
    pkgs.eww
    pkgs.jq
    pkgs.networkmanager_dmenu # network manager via dmenu
  ];
}
