{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.programs.lazygit;
in
{
  config = mkIf cfg.enable {
    home.packages = [ pkgs.lazygit ];

    # Lazygit configuration
    xdg.configFile."lazygit/config.yml".source = ./config.yml;

    # Shell alias for lazygit
    programs.zsh.shellAliases.lg = mkIf config.programs.zsh.enable "lazygit";
    programs.bash.shellAliases.lg = mkIf config.programs.bash.enable "lazygit";
    programs.fish.shellAliases.lg = mkIf config.programs.fish.enable "lazygit";
  };
}
