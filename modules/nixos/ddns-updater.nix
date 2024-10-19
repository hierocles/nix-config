{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ddns-updater;
in {
  options.modules.ddns-updater = {
    enable = lib.mkEnableOption "ddns";
    configFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the ddns-updater config file";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.ddns-updater
    ];

    users.users.ddns-updater = {
      isSystemUser = true;
      group = "ddns-updater";
      home = "/var/lib/ddns-updater";
      createHome = true;
    };
    users.groups.ddns-updater = {};

    systemd.services.ddns-updater = {
      enable = true;
      description = "DDNS Updater";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        User = "ddns-updater";
        Group = "ddns-updater";
        ExecStart = "${pkgs.ddns-updater}/bin/ddns-updater -c /var/lib/ddns-updater/data/config.json -p 8989";
        WorkingDirectory = "/var/lib/ddns-updater";
        StateDirectory = "ddns-updater";
        StateDirectoryMode = "0750";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
    # system.activationScripts = {
    #   ddns-updater-config = ''
    #     mkdir -p /var/lib/ddns-updater/data
    #     cp ${cfg.configFile} /var/lib/ddns-updater/data/config.json
    #     chmod 600 /var/lib/ddns-updater/data/config.json
    #     chown -R ddns-updater:ddns-updater /var/lib/ddns-updater
    #   '';
    # };
    systemd.tmpfiles.rules = [
      "d /var/lib/ddns-updater 0750 ddns-updater ddns-updater - -"
    ];
  };
}
