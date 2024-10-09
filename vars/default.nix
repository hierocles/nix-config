{
  inputs,
  lib,
  ...
}: let
  # Default value, can be overridden
  defaultIsMinimal = false;
in
  rec {
    isMinimal = defaultIsMinimal;

    # Conditionally include secrets
    secrets =
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

    username = "dylan";
    handle = "hierocles";
    gitHubEmail = "4733259+hierocles@users.noreply.github.com";

    # System-specific settings (FIXME: Likely make options)
    isWork = false; # Used to indicate a host that uses work resources
    scaling = "1"; # Used to indicate what scaling to use. Floating point number

    # Merge secrets into the main set
    # This ensures secrets are included in the output when !isMinimal
  }
  // secrets
