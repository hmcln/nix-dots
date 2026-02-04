{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.modules.programs.foot;
in
{
  config = mkIf cfg.enable {
    programs.foot = {
      enable = true;

      settings = {
        main = {
          shell = "fish";
          title = "foot";
          font = "JetBrains Mono Nerd Font:size=12";
          letter-spacing = 0;
          dpi-aware = false;
          pad = "25x25";
          bold-text-in-bright = false;
          gamma-correct-blending = false;
        };

        scrollback = {
          lines = 10000;
        };

        cursor = {
          style = "beam";
          beam-thickness = 1.5;
        };

        colors = {
          alpha = 0.78;
        };

        key-bindings = {
          scrollback-up-page = "Page_Up";
          scrollback-down-page = "Page_Down";
          search-start = "Control+Shift+f";
        };

        search-bindings = {
          cancel = "Escape";
          find-prev = "Shift+F3";
          find-next = "F3 Control+G";
        };
      };
    };
  };
}
