{
  # Let it try to start a few more times
  systemd.user.services.waybar = {
    Unit.StartLimitBurst = 30;
  };
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target"; # NOTE = hyprland/default.nix stops graphical-session.target and starts hyprland-sessionl.target
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = [
          "HDMI-A-1"
        ];
        modules-left = [
          "hyprland/workspaces"
          "hyprland/mode"
        ];
        modules-center = ["hyprland/window"];
        modules-right = [
          "pulseaudio"
          "tray"
          "network"
          "clock#time"
          "clock#date"
        ];

        #
        # ========= Modules =========
        #

        #TODO
        #"hyprland/window" ={};

        "hyprland/workspaces" = {
          all-outputs = false;
          disable-scroll = true;
          on-click = "actviate";
          show-special = true; # display special workspaces along side regular ones (scratch for example)
        };
        "clock#time" = {
          interval = 1;
          format = "{:%H:%M}";
          tooltip = false;
        };
        "clock#date" = {
          interval = 10;
          format = "{:%d.%b.%y.%a}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        "network" = {
          format-ethernet = "{ipaddr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          on-click = "networkmanager_dmenu";
        };
        "pulseaudio" = {
          "format" = "{volume}% {icon}";
          #              "format-source" = "Mic ON";
          #              "format-source-muted" = "Mic OFF";
          "format-bluetooth" = "{volume}% {icon}";
          "format-muted" = "";
          "format-icons" = {
            "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
            "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "phone-muted" = "";
            "portable" = "";
            "car" = "";
            "default" = [
              ""
              ""
            ];
          };
          "scroll-step" = 1;
          "on-click" = "pavucontrol";
          "ignored-sinks" = ["Easy Effects Sink"];
        };
        "tray" = {
          spacing = 10;
        };
      };
    };
  };
}
