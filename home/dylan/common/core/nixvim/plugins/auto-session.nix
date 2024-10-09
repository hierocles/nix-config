{
  config,
  lib,
  ...
}: {
  options = {
    nixvim-config.plugins.auto-session.enable = lib.mkEnableOption "enables auto-session module";
  };

  config = lib.mkIf config.nixvim-config.plugins.auto-session.enable {
    programs.nixvim.plugins = {
      auto-session = {
        enable = true;
        settings = {
          log_level = "error";
          use_git_branch = true;
          suppressed_dirs = [
            "~/"
            "~/downloads"
            "~/doc"
            "~/tmp"
          ];
          auto_restore = true;
          auto_save = true;
        };
      };
    };
  };
}
