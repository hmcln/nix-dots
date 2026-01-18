{ lib, ... }:

with lib;

{
  options.modules.desktop.hyprland = {
    enable = mkEnableOption "Hyprland window manager configuration";

    monitors = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Monitor configurations";
      example = [
        "HDMI-A-1,3840x2160,-2560x-540,1.5"
        "DP-1,2560x1440,-2560x0,1"
      ];
    };

    workspaces = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "Workspace configurations";
      example = [
        { id = 1; monitor = 0; persistent = true; }
        { id = 6; monitor = 1; persistent = true; }
      ];
    };

    variables = {
      terminal = mkOption {
        type = types.str;
        default = "foot";
        description = "Default terminal emulator";
      };

      browser = mkOption {
        type = types.str;
        default = "chromium";
        description = "Default web browser";
      };

      editor = mkOption {
        type = types.str;
        default = "codium";
        description = "Default code editor";
      };

      fileExplorer = mkOption {
        type = types.str;
        default = "thunar";
        description = "Default file explorer";
      };

      cursorTheme = mkOption {
        type = types.str;
        default = "sweet-cursors";
        description = "Cursor theme name";
      };

      cursorSize = mkOption {
        type = types.int;
        default = 24;
        description = "Cursor size";
      };

      volumeStep = mkOption {
        type = types.int;
        default = 10;
        description = "Volume step percentage";
      };
    };

    touchpad = {
      disableTyping = mkOption {
        type = types.bool;
        default = true;
        description = "Disable touchpad while typing";
      };

      scrollFactor = mkOption {
        type = types.float;
        default = 0.3;
        description = "Touchpad scroll factor";
      };
    };

    gestures = {
      workspaceSwipeFingers = mkOption {
        type = types.int;
        default = 4;
        description = "Number of fingers for workspace swipe";
      };

      fingers = mkOption {
        type = types.int;
        default = 3;
        description = "Number of fingers for basic gestures";
      };

      fingersMore = mkOption {
        type = types.int;
        default = 4;
        description = "Number of fingers for advanced gestures";
      };
    };

    blur = {
      enabled = mkOption {
        type = types.bool;
        default = true;
        description = "Enable blur effects";
      };

      specialWs = mkOption {
        type = types.bool;
        default = false;
        description = "Blur special workspaces";
      };

      popups = mkOption {
        type = types.bool;
        default = true;
        description = "Blur popups";
      };

      inputMethods = mkOption {
        type = types.bool;
        default = true;
        description = "Blur input methods";
      };

      size = mkOption {
        type = types.int;
        default = 8;
        description = "Blur size";
      };

      passes = mkOption {
        type = types.int;
        default = 2;
        description = "Number of blur passes";
      };

      xray = mkOption {
        type = types.bool;
        default = false;
        description = "Blur xray mode";
      };
    };

    shadow = {
      enabled = mkOption {
        type = types.bool;
        default = true;
        description = "Enable window shadows";
      };

      range = mkOption {
        type = types.int;
        default = 20;
        description = "Shadow range";
      };

      renderPower = mkOption {
        type = types.int;
        default = 3;
        description = "Shadow render power";
      };
    };

    gaps = {
      workspace = mkOption {
        type = types.int;
        default = 20;
        description = "Workspace gaps";
      };

      windowIn = mkOption {
        type = types.int;
        default = 5;
        description = "Inner window gaps";
      };

      windowOut = mkOption {
        type = types.int;
        default = 20;
        description = "Outer window gaps";
      };

      singleWindowOut = mkOption {
        type = types.int;
        default = 20;
        description = "Single window outer gaps";
      };
    };

    window = {
      opacity = mkOption {
        type = types.float;
        default = 0.95;
        description = "Window opacity";
      };

      rounding = mkOption {
        type = types.int;
        default = 10;
        description = "Window corner rounding";
      };

      borderSize = mkOption {
        type = types.int;
        default = 3;
        description = "Window border size";
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra Hyprland configuration";
    };
  };
}
