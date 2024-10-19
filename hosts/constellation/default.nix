###################################################
#                                                 #
#       Constellation - Media Server              #
#                                                 #
#       NixOS running on Intel Celeron 5105       #
#       with iGPU and 2TB NVMe SSD                #
#       with ZFS pool for media                   #
#                                                 #
###################################################
{
  inputs,
  lib,
  configLib,
  configVars,
  pkgs,
  config,
  ...
}: let
  isUnstable = config.boot.zfs.package == pkgs.zfsUnstable;
  zfsCompatibleKernelPackages =
    lib.filterAttrs (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name)
        != null
        && (builtins.tryEval kernelPackages).success
        && (
          (!isUnstable && !kernelPackages.zfs.meta.broken)
          || (isUnstable && !kernelPackages.zfs_unstable.meta.broken)
        )
    )
    pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );

  plexPort = configVars.networking.nat.plex.sourcePort;
  ipv4Address = configVars.networking.ipv4.constellation.lanIP;
  ipv4PrefixLength = configVars.networking.ipv4.constellation.prefixLength;
in {
  imports = lib.flatten [
    #################### Every Host Needs This ####################
    ./hardware-configuration.nix

    #################### Hardware Modules ####################
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    #################### Disk Layout ####################
    inputs.disko.nixosModules.disko
    (configLib.relativeToRoot "hosts/common/disks/constellation.nix")

    (map configLib.relativeToRoot [
      #################### Required Configs ####################
      "hosts/common/core"

      #################### Host-specific Optional Configs ####################
      "hosts/common/optional/services/openssh.nix" # allow remote SSH access
      "hosts/common/optional/services/adguard.nix"
      "hosts/common/optional/libvirt.nix" # vm tools
      "hosts/common/optional/thunar.nix" # file manager
      "hosts/common/optional/audio.nix" # pipewire and cli controls
      "hosts/common/optional/vlc.nix" # media player

      #################### Desktop ####################
      "hosts/common/optional/services/greetd.nix" # display manager
      "hosts/common/optional/hyprland.nix" # window manager
      "hosts/common/optional/wayland.nix" # wayland components and pkgs not avaialble in home-manager

      #################### *Arr ####################
      "hosts/common/optional/services/servarr.nix"
      "hosts/common/optional/services/auth.nix"
      "hosts/common/optional/services/recyclarr.nix"
      "hosts/common/optional/services/vpn.nix"
    ])
    #################### Constellation Specific ####################
    ./samba.nix
  ];

  networking = {
    hostName = "constellation";
    hostId = "9a5b5e9c";
    networkmanager.enable = true;
    enableIPv6 = true;
    interfaces.enp3s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = ipv4Address;
          prefixLength = ipv4PrefixLength;
        }
      ];
      # IPv6 configuration is handled by SLAAC
    };
    defaultGateway = "192.168.0.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp3s0";
    };
    nameservers = ["1.1.1.1" "1.0.0.1"];
    firewall = {
      enable = true;
      allowedTCPPorts = [plexPort];
    };
  };

  boot = {
    kernelPackages = latestKernelPackage;
    supportedFilesystems = ["zfs"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    initrd = {
      systemd.enable = true;
      kernelModules = ["i915" "zfs"];
    };
    zfs = {
      devNodes = "/dev/disk/by-id";
      extraPools = ["mediapool"];
    };
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      pools = ["mediapool"];
      interval = "monthly";
    };
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion

  #TODO: move this stuff to separate file but define theme itself per host
  # host-wide styling
  stylix = {
    enable = true;
    image = /home/dylan/sync/wallpaper/wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 0.8;
    };
    polarity = "dark";
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
