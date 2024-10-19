{
  config,
  lib,
  ...
}: let
  cfg = config.modules.redis;
in {
  options.modules.redis = {
    enable = lib.mkEnableOption "redis";
    bind = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 6379;
    };
    name = lib.mkOption {
      type = lib.types.str;
      default = "default";
    };
  };
  config = lib.mkIf cfg.enable {
    services.redis = {
      servers.${cfg.name} = {
        enable = true;
        port = cfg.port;
        bind = cfg.bind;
      };
    };
  };
}
