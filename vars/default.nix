{
  inputs,
  lib,
  ...
}: let
  # Default value, can be overridden
  defaultIsMinimal = false;

  # Define secrets function outside the main set
  getSecrets = isMinimal:
    if !isMinimal
    then {
      inherit
        (inputs.nix-secrets)
        userFullName
        domain
        email
        networking
        ;
    }
    else {};
in rec {
  isMinimal = defaultIsMinimal;

  username = "dylan";
  handle = "hierocles";
  gitHubEmail = "4733259+hierocles@users.noreply.github.com";

  # System-specific settings (FIXME: Likely make options)
  isWork = false; # Used to indicate a host that uses work resources
  scaling = "1"; # Used to indicate what scaling to use. Floating point number

  # Include secrets based on isMinimal
  secrets = getSecrets isMinimal;
}
