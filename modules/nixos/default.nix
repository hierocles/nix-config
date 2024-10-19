# Add your reusable nixos modules to this directory, on their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# These should be stuff you would like to share with others, not your personal configurations.
{
  imports = [
    ./servarr.nix
    ./traefik.nix
    ./authelia.nix
    ./redis.nix
    ./ddns-updater.nix
    ./cross-seed.nix
  ];
}
