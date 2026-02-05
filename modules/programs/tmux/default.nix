{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.programs.tmux;
in
{
  config = mkIf cfg.enable {
    # Write tmux.conf directly to avoid Home Manager prepending defaults
    xdg.configFile."tmux/tmux.conf".source = ./tmux.conf;

    # Still need tmux package installed
    home.packages = [ pkgs.tmux ];
  };
}
