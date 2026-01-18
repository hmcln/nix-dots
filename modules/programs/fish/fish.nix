{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.programs.fish;
in
{
  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;

      # Basic fish configuration
      shellInit = ''
        # Fish shell initialization
      '';

      interactiveShellInit = ''
        # Apply Caelestia color scheme to terminal (only for interactive shells)
        if test -f ~/.local/state/caelestia/sequences.txt
          cat ~/.local/state/caelestia/sequences.txt
        end
      '';
    };

    # Store-managed config files/directories
    xdg.configFile."fish/functions" = {
      source = ./functions;
      recursive = true;
    };

    home.packages = with pkgs; [
      eza
      direnv
      zoxide
    ];

    home.sessionVariables = { };
  };
}
