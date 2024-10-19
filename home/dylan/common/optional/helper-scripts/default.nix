{
  pkgs,
  configVars,
  ...
}: let
  scripts = {
    # FIXME: I currently get the following warnings:
    # svn: warning: cannot set LC_CTYPE locale
    # svn: warning: environment variable LANG is en_US.UTF-8
    # svn: warning: please check that your locale name is correct
    copy-github-subfolder = pkgs.writeShellApplication {
      name = "copy-github-subfolder";
      runtimeInputs = [pkgs.subversion];
      text = builtins.readFile ./copy-github-subfolder.sh;
    };
    linktree = pkgs.writeShellApplication {
      name = "linktree";
      runtimeInputs = [];
      text = builtins.readFile ./linktree.sh;
    };
    trash_guides_radarr = pkgs.writeShellApplication {
      name = "trash_guides_radarr";
      runtimeInputs = [pkgs.curl pkgs.jq];
      text = ''
        export USER_EMAIL="${configVars.email.user}"
        ${builtins.readFile ./trash_guides_radarr.sh}
      '';
    };
    trash_guides_sonarr = pkgs.writeShellApplication {
      name = "trash_guides_sonarr";
      runtimeInputs = [pkgs.curl pkgs.jq];
      text = ''
        export USER_EMAIL="${configVars.email.user}"
        ${builtins.readFile ./trash_guides_sonarr.sh}
      '';
    };
  };
in {
  home.packages = builtins.attrValues {inherit (scripts) copy-github-subfolder linktree trash_guides_radarr trash_guides_sonarr;};
}
