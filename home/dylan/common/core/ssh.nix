{
  config,
  configVars,
  configLib,
  lib,
  ...
}: let
  pathtokeys = configLib.relativeToRoot "hosts/common/users/${configVars.username}/keys";

  identityFiles = [
    "id_constellation"
    "dylan" # fallback to dylan if yubikeys are not present
  ];

  # Lots of hosts have the same default config, so don't duplicate
  vanillaHosts = [
    "constellation"
  ];
  vanillaHostsConfig = lib.attrsets.mergeAttrsList (
    lib.lists.map (host: {
      "${host}" = lib.hm.dag.entryAfter ["yubikey-hosts"] {
        host = host;
        hostname = "${host}.${configVars.domain}";
        port = configVars.networking.ports.tcp.ssh;
      };
    })
    vanillaHosts
  );
in {
  programs.ssh = {
    enable = true;

    # FIXME: This should probably be for git systems only?
    controlMaster = "auto";
    controlPath = "~/.ssh/sockets/S.%r@%h:%p";
    controlPersist = "10m";

    # req'd for enabling yubikey-agent
    extraConfig = ''
      AddKeysToAgent yes
    '';

    matchBlocks =
      {
        "git" = {
          host = "github.com";
          user = "git";
          forwardAgent = true;
          identitiesOnly = true;
          identityFile = lib.lists.forEach identityFiles (file: "${config.home.homeDirectory}/.ssh/${file}");
        };
      }
      // vanillaHostsConfig;
  };
  home.file = {
    ".ssh/config.d/.keep".text = "# Managed by Home Manager";
    ".ssh/sockets/.keep".text = "# Managed by Home Manager";
  };
}
