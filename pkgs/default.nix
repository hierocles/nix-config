# You can build these directly using 'nix build .#example'
{pkgs ? import <nixpkgs> {}}: let
  click-params = pkgs.callPackage ./click-params {};
  buildarr = pkgs.callPackage ./buildarr {inherit click-params;};
  buildarr-sonarr = pkgs.callPackage ./buildarr-sonarr {inherit buildarr;};
  buildarr-radarr = pkgs.callPackage ./buildarr-radarr {inherit buildarr;};
in {
  #################### Packages with external source ####################

  cd-gitroot = pkgs.callPackage ./cd-gitroot {};
  zhooks = pkgs.callPackage ./zhooks {};
  zsh-term-title = pkgs.callPackage ./zsh-term-title {};
  gruvbox-factory = pkgs.callPackage ./gruvbox-factory {};
  click-params = click-params;
  buildarr = buildarr;
  buildarr-sonarr = buildarr-sonarr;
  buildarr-radarr = buildarr-radarr;
  buildarr-prowlarr = pkgs.callPackage ./buildarr-prowlarr {inherit buildarr buildarr-sonarr buildarr-radarr;};
  buildarr-jellyseerr = pkgs.callPackage ./buildarr-jellyseerr {inherit buildarr buildarr-sonarr buildarr-radarr;};
}
