{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.style.cursor;
in
{
  options.modules.desktop.style.cursor = {
    enable = mkEnableOption "custom cursor theme";

    package = mkPackageOption pkgs "bibata-cursors" { };

    name = mkOption {
      type = types.str;
      default = "Bibata-Modern-Classic";
      description = "Cursor name";
    };

    size = mkOption {
      type = types.int;
      default = 24;
      description = "Cursor size in pixels";
    };
  };

  config = mkIf cfg.enable {
    home.pointerCursor = {
      name = cfg.name;
      package = cfg.package;
      size = cfg.size;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk.cursorTheme = {
      name = cfg.name;
      package = cfg.package;
      size = cfg.size;
    };

    home.sessionVariables = {
      XCURSOR_THEME = cfg.name;
      XCURSOR_SIZE = toString cfg.size;
    };
  };
}
