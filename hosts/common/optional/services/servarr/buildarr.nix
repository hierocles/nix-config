{
  pkgs,
  inputs,
  ...
}: let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  secretsFile = "${secretsDirectory}/buildarr.yaml";
in {
  environment.systemPackages = with pkgs; [
    click-params
    buildarr
    buildarr-sonarr
    buildarr-radarr
    buildarr-prowlarr
    buildarr-jellyseerr
  ];

  systemd.services.buildarr = {
    description = "Buildarr Service";
    after = ["network.target"];
    # wantedBy = ["multi-user.target"];  # Start on boot
    serviceConfig = {
      Type = "simple";
      User = "buildarr";
      Group = "buildarr";
      ExecStart = ''
        ${pkgs.python3.withPackages (ps:
          with ps; [
            buildarr
            buildarr-sonarr
            buildarr-radarr
            buildarr-prowlarr
            buildarr-jellyseerr
          ])}/bin/buildarr --config /var/lib/buildarr/buildarr.yaml
      '';
      Restart = "on-failure";
      RestartSec = "5s";
    };
    preStart = ''
      ${pkgs.coreutils}/bin/cp ${secretsFile} /var/lib/buildarr/buildarr.yaml
      ${pkgs.coreutils}/bin/chown buildarr:buildarr /var/lib/buildarr/buildarr.yaml
      ${pkgs.coreutils}/bin/chmod 600 /var/lib/buildarr/buildarr.yaml
    '';
  };

  users.users.buildarr = {
    isSystemUser = true;
    group = "buildarr";
    description = "Buildarr service user";
    home = "/var/lib/buildarr";
    createHome = true;
  };

  users.groups.buildarr = {};
}
