{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-gui"
      "1password"
      "1password-cli"
      "slack"
      "todoist-electron"
      "spotify"
    ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "hamish" ];
  };

  # Note: hardware-configuration.nix and hostname are imported from hosts/<machine>/default.nix

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager.enable = true;

  time.timeZone = "Australia/Melbourne";

  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  services.xserver.xkb.layout = "au";

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "hyprland";
  services.gnome.gnome-keyring.enable = true;
  programs.hyprland.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Power management - enables power profiles daemon for quickshell
  services.power-profiles-daemon.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];

    config = {
      common = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Settings" = [
          "darkman"
          "gtk"
        ];
      };
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
  };

  users.groups.hamish = { };

  users.users.hamish = {
    isNormalUser = true;
    group = "hamish";
    description = "Hamish McLean";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICUIgdznO0AC6sZE3EThR0CWvq2m+avxtWc7U2menxTU hamish@nixos"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    gcc
    unzip
    curl
    zlib
    gnumake
    glib
    gsettings-desktop-schemas
    dconf
    adwaita-icon-theme
    hicolor-icon-theme
    gnome-themes-extra
  ];

  virtualisation.docker = {
    enable = true;
  };

  programs.dconf.enable = true;

  programs.fish.enable = true;

  fonts.packages = with pkgs; [
    dejavu_fonts
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "25.05";
}
