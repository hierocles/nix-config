# hosts level sops. see home/[user]/common/optional/sops.nix for home/user level
{
  pkgs,
  inputs,
  config,
  configVars,
  ...
}: let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  secretsFile = "${secretsDirectory}/secrets.yaml";

  # FIXME: Switch to a configLib function
  homeDirectory =
    if pkgs.stdenv.isLinux
    then "/home/${configVars.username}"
    else "/Users/${configVars.username}";
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops = {
    defaultSopsFile = "${secretsFile}";
    validateSopsFiles = false;

    age = {
      # automatically import host SSH keys as age keys
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };

    secrets = {
      "user_age_keys/${configVars.username}_${config.networking.hostName}" = {
        owner = config.users.users.${configVars.username}.name;
        inherit (config.users.users.${configVars.username}) group;
        path = "${homeDirectory}/.config/sops/age/keys.txt";
      };

      "${configVars.username}/password".neededForUsers = true;

      "ssh_keys/dylan" = {};
      "ssh_keys/id_constellation" = {};
      "smb-secrets" = {};
      wireguard = {};
      transmission = {};
      "authelia-jwt-secret" = {};
      "authelia-session-secret" = {};
      "authelia-storage-encryption-key" = {};
      "authelia-users" = {};
      "ddns-updater-config" = {
        owner = "ddns-updater";
        group = "ddns-updater";
      };
    };
  };
  # The containing folders are created as root and if this is the first ~/.config/ entry,
  # the ownership is busted and home-manager can't target because it can't write into .config...
  # FIXME: We might not need this depending on how https://github.com/Mic92/sops-nix/issues/381 is fixed
  system.activationScripts.sopsSetAgeKeyOwnwership = let
    ageFolder = "${homeDirectory}/.config/sops/age";
    user = config.users.users.${configVars.username}.name;
    group = config.users.users.${configVars.username}.group;
  in ''
    mkdir -p ${ageFolder} || true
    chown -R ${user}:${group} ${homeDirectory}/.config
  '';
}
