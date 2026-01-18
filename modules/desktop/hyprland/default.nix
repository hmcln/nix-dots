{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.hyprland;
in
{
  imports = [
    ./options.nix
    ./settings.nix
    ./keybinds.nix
    ./rules.nix
  ];

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Create required directories and files
    home.activation.createHyprlandDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${config.home.homeDirectory}/.config/hypr/scheme
      mkdir -p ${config.home.homeDirectory}/.config/caelestia
      touch ${config.home.homeDirectory}/.config/caelestia/hypr-vars.conf
      touch ${config.home.homeDirectory}/.config/caelestia/hypr-user.conf
    '';

    # Copy color scheme files (if they exist)
    home.file.".config/hypr/scheme/default.conf" = mkIf (builtins.pathExists /home/hamish/dotfiles/hypr/scheme/default.conf) {
      source = /home/hamish/dotfiles/hypr/scheme/default.conf;
    };

    home.file.".config/hypr/scheme/current.conf" = mkIf (builtins.pathExists /home/hamish/dotfiles/hypr/scheme/current.conf) {
      source = /home/hamish/dotfiles/hypr/scheme/current.conf;
    };
  };
}
