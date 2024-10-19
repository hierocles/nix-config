{
  lib,
  pkgs,
  config,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    input = {
      follow_mouse = 2;
      # follow_mouse options:
      # 0 - Cursor movement will not change focus.
      # 1 - Cursor movement will always change focus to the window under the cursor.
      # 2 - Cursor focus will be detached from keyboard focus. Clicking on a window will move keyboard focus to that window.
      # 3 - Cursor focus will be completely separate from keyboard focus. Clicking on a window will not change keyboard focus.
      mouse_refocus = false;
    };

    bindm = [
      "ALT,mouse:272,movewindow"
      "ALT,mouse:273,resizewindow"
    ];

    bind = let
      workspaces = [
        "0"
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
        "F1"
        "F2"
        "F3"
        "F4"
        "F5"
        "F6"
        "F7"
        "F8"
        "F9"
        "F10"
        "F11"
        "F12"
      ];
      # Map keys (arrows and hjkl) to hyprland directions (l, r, u, d)
      directions = rec {
        left = "l";
        right = "r";
        up = "u";
        down = "d";
        h = left;
        l = right;
        k = up;
        j = down;
      };
      pactl = lib.getExe' pkgs.pulseaudio "pactl"; # installed via /hosts/common/optional/audio.nix
    in
      lib.flatten [
        #################### Program Launch ####################
        "ALT,Return,exec,kitty"
        "CTRL_ALT,v,exec,kitty nvim"
        "SUPER,space,exec,rofi -show run"
        "ALT,tab,exec,rofi -show window"
        "CTRL_ALT,f,exec,thunar"

        "CTRL_ALT,8,exec,grimblast --notify --freeze copy area"
        ",Print,exec,grimblast --notify --freeze copy area"

        #################### Basic Bindings ####################
        #reload the configuration file
        "SHIFTALT,r,exec,hyprctl reload"
        "SHIFTALT,q,killactive"
        "ALT,s,togglesplit"
        "ALT,f,fullscreen,0"
        "SHIFTALT,space,togglefloating"
        "SHIFTALT, p, pin"
        "SHIFALT, r, resizeactive"
        "ALT,g,togglegroup"
        "ALT,t,lockactivegroup,toggle"
        "ALT,apostrophe,changegroupactive,f"
        "SHIFTALT,apostrophe,changegroupactive,b"
        "ALT,-,togglespecialworkspace"
        "SHIFTALT,-,movetoworkspace,special"

        #################### Media Controls ####################
        # Output
        ", XF86AudioMute, exec, ${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioRaiseVolume, exec, ${pactl} set-sink-volume @DEFAULT_SINK@ +1%"
        ", XF86AudioLowerVolume, exec, ${pactl} set-sink-volume @DEFAULT_SINK@ -1%"
        # Input
        ", XF86AudioMute, exec, ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ", XF86AudioRaiseVolume, exec, ${pactl} set-source-volume @DEFAULT_SOURCE@ +1%"
        ", XF86AudioLowerVolume, exec, ${pactl} set-source-volume @DEFAULT_SOURCE@ -1%"
        # Player controls
        #FIXME For some reason these key pressings aren't firing from Moonlander. Nothing shows when running wev
        ", XF86AudioPlay, exec, 'playerctl --ignore-player=firefox,chromium play-pause'"
        ", XF86AudioNext, exec, 'playerctl --ignore-player=firefox,chromium next'"
        ", XF86AudioPrev, exec, 'playerctl --ignore-player=firefox,chromium previous'"

        # Change workspace
        (map (n: "ALT,${n},workspace,name:${n}") workspaces)

        # Move window to workspace
        (map (n: "SHIFTALT,${n},movetoworkspace,name:${n}") workspaces)

        # Move focus
        (lib.mapAttrsToList (key: direction: "ALT,${key},movefocus,${direction}") directions)

        # Move windows
        (lib.mapAttrsToList (key: direction: "SHIFTALT,${key},movewindow,${direction}") directions)
      ];
  };
}
