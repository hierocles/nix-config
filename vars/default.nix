{inputs, ...}: {
  inherit
    (inputs.nix-secrets)
    userFullName
    domain
    email
    networking
    wireguard
    ;

  username = "dylan";
  handle = "hierocles";
  gitHubEmail = "4733259+hierocles@users.noreply.github.com";

  # System-specific settings (FIXME: Likely make options)
  isMinimal = false; # Used to indicate nixos-installer build
  isWork = false; # Used to indicate a host that uses work resources
  scaling = "1"; # Used to indicate what scaling to use. Floating point number
}
