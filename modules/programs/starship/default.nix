{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.programs.starship;
in
{
  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;

      # Symlink to dotfiles starship.toml so it can be edited without rebuilding
      # Note: starship doesn't support shellInit like fish, so we use home.file
    };

    # Link starship config from dotfiles
    xdg.configFile."starship.toml".source = ./starship.toml;
  };
}
