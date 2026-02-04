{ lib, config, pkgs, ... }:

with lib;

{
  imports = [
    ./btop
    ./foot
    ./lazygit
    ./fish
    ./starship
    ./tmux
    ./caelestia.nix
    ./caelestia-sync.nix
    ./neovim.nix
  ];

  options.modules.programs = {
    neovim = {
      enable = mkEnableOption "Neovim text editor";

      neovide = {
        enable = mkEnableOption "Neovide GUI for Neovim";
      };
    };

    btop = {
      enable = mkEnableOption "btop system monitor";
    };

    foot = {
      enable = mkEnableOption "foot terminal emulator";
    };

    lazygit = {
      enable = mkEnableOption "lazygit TUI for git";
    };

    fish = {
      enable = mkEnableOption "Fish shell";
    };

    starship = {
      enable = mkEnableOption "Starship prompt";
    };

    tmux = {
      enable = mkEnableOption "tmux terminal multiplexer";
    };
  };

  config = {
    # Default configurations can go here
  };
}
