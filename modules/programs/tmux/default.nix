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
    programs.tmux = {
      enable = true;
    };
  };
}
