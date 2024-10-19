{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    # custom key binds
    ./binds.nix
  ];

  # NOTE: xdg portal package is currently set in /hosts/common/optional/hyprland.nix

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = ["--all"]; # fix for https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
      #   # TODO: experiment with whether this is required.
      #   # Same as default, but stop the graphical session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };

    settings = {
      env = [
        "NIXOS_OZONE_WL, 1" # for ozone-based and electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND, 1" # for firefox to run on wayland
        "MOZ_WEBRENDER, 1" # for firefox to run on wayland
        "XDG_SESSION_TYPE,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
        "WLR_RENDERER_ALLOW_SOFTWARE,1"
        "QT_QPA_PLATFORM,wayland"
      ];

      # Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.
      # https://wiki.hyprland.org/Configuring/Monitors/
      monitor = [
        "HDMI-A-1, 3440x1440@50, 0x0, 1"
      ];

      workspace = [
        "1, monitor:HDMI-A-1, default:true, persistent:true"
        "2, monitor:HDMI-A-1, default:true"
        "3, monitor:HDMI-A-1, default:true"
        "4, monitor:HDMI-A-1, default:true"
        "5, monitor:HDMI-A-1, default:true"
        "6, monitor:HDMI-A-1, default:true"
        "7, monitor:HDMI-A-1, default:true"
        "8, monitor:HDMI-A-1, default:true"
        "9, monitor:HDMI-A-1, default:true"
        "0, monitor:HDMI-A-1, default:true"
      ];

      general = {
        gaps_in = 6;
        gaps_out = 6;
        border_size = 0;
        resize_on_border = true;
        hover_icon_on_border = true;
        layout = "master";
      };
      #general bindings. for keybinds see ./binds.nix
      binds = {
        workspace_center_on = 1; # Whether switching workspaces should center the cursor on the workspace (0) or on the last active window for that workspace (1)
        movefocus_cycles_fullscreen = false; # If enabled, when on a fullscreen window, movefocus will cycle fullscreen, if not, it will move the focus in a direction.
      };
      cursor.inactive_timeout = 10;
      decoration = {
        active_opacity = 1.0;
        inactive_opacity = 0.85;
        fullscreen_opacity = 1.0;
        rounding = 10;
        blur = {
          enabled = false;
          size = 5;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          popups = true;
        };
        drop_shadow = true;
        shadow_range = 12;
        shadow_offset = "3 3";
      };
      misc = {
        #  disable_hyprland_logo = true;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        #  disable_autoreload = true;
        new_window_takes_over_fullscreen = 2; # 0 - behind, 1 - takes over, 2 - unfullscreen/unmaxize [0/1/2]
        middle_click_paste = false;
      };

      # Autostart applications
      # exec-once = ''${startupScript}/path'';
      exec-once = [
        ''${pkgs.copyq}/bin/copyq''
      ];
      windowrule = [
        # Dialogs
        "float, title:^(Open File)(.*)$"
        "float, title:^(Select a File)(.*)$"
        "float, title:^(Choose wallpaper)(.*)$"
        "float, title:^(Open Folder)(.*)$"
        "float, title:^(Save As)(.*)$"
        "float, title:^(Library)(.*)$"
        "float, title:^(Accounts)(.*)$"
      ];

      windowrulev2 = let
        flameshot = "class:^(flameshot)$,title:^(flameshot)$";
      in [
        "float, class:^(galculator)$"
        "float, class:^(waypaper)$"

        # flameshot currently doesn't have great wayland support so needs some tweaks
        #          "monitor DP-1, ${flameshot}"
        "rounding 0, ${flameshot}"
        "noborder, ${flameshot}"
        "float, ${flameshot}"
        "move 0 0, ${flameshot}"
        "suppressevent fullscreen, ${flameshot}"
      ];

      # load at the end of the hyperland set
      # extraConfig = '''';
    };
  };
}
