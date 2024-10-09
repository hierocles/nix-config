{
  inputs,
  lib,
  ...
}: let
  # Default value, can be overridden
  defaultIsMinimal = false;

  # Function to get secrets or null values
  getSecrets = isMinimal:
    if !isMinimal
    then inputs.nix-secrets
    else {
      userFullName = null;
      domain = null;
      email = null;
      networking = null;
    };
in rec {
  isMinimal = defaultIsMinimal;

  username = "dylan";
  handle = "hierocles";
  gitHubEmail = "4733259+hierocles@users.noreply.github.com";

  # System-specific settings (FIXME: Likely make options)
  isWork = false; # Used to indicate a host that uses work resources
  scaling = "1"; # Used to indicate what scaling to use. Floating point number

  # Include secrets or null values based on isMinimal
  userFullName = (getSecrets isMinimal).userFullName;
  domain = (getSecrets isMinimal).domain;
  email = (getSecrets isMinimal).email;
  networking = (getSecrets isMinimal).networking;
}
