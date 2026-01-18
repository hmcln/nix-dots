{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.modules.programs.caelestia;

  # Determine which wallpaper backend to use
  wallpaperBackend = if cfg.wallpaperBackend == "swww" then "swww" else "hyprpaper";

  # Post-hook script for setting wallpaper
  postHookScript = pkgs.writeShellScript "caelestia-wallpaper-hook" ''
    # Set wallpaper using the configured backend
    ${if cfg.wallpaperBackend == "swww" then ''
      ${pkgs.swww}/bin/swww img "$WALLPAPER_PATH" \
        --transition-type ${cfg.swww.transitionType} \
        --transition-duration ${toString cfg.swww.transitionDuration}
    '' else ''
      # hyprpaper requires manual configuration
      # The wallpaper path is available in $WALLPAPER_PATH
      echo "Using hyprpaper - configure manually in hyprland.conf"
    ''}
  '';

  # CLI configuration
  cliConfig = {
    wallpaper = {
      postHook = toString postHookScript;
    };

    toggles = {
      communication = {
        discord = {
          enable = false;
        };
        slack = {
          enable = true;
          match = [
            { class = "Slack"; }
            { title = "Slack"; }
            { initialTitle = "Slack"; }
          ];
          command = [ "slack" ];
          move = true;
        };
      };
      notes = {
        pkm = {
          enable = true;
          match = [
            { title = "PKM"; }
          ];
          command = [ "foot" "-T" "PKM" "fish" "-lc" "exec nvim ~/notes" ];
          move = true;
        };
      };
    };

    theme = {
      # Enable user-writable configs (these work fine on NixOS)
      enableTerm = cfg.theme.enableTerm;
      enableHypr = cfg.theme.enableHypr;
      enableDiscord = cfg.theme.enableDiscord;
      enableSpicetify = cfg.theme.enableSpicetify;
      enableFuzzel = cfg.theme.enableFuzzel;
      enableBtop = cfg.theme.enableBtop;
      enableNvtop = cfg.theme.enableNvtop;
      enableHtop = cfg.theme.enableHtop;
      enableWarp = cfg.theme.enableWarp;
      enableCava = cfg.theme.enableCava;

      # Disable configs that fail on NixOS (read-only /nix/store)
      enableGtk = false;
      enableQt = false;
    };
  };
in
{
  options.modules.programs.caelestia = {
    enable = mkEnableOption "Caelestia wallpaper and theming system";

    wallpaperBackend = mkOption {
      type = types.enum [ "swww" "hyprpaper" ];
      default = "swww";
      description = "Which wallpaper backend to use";
    };

    swww = {
      transitionType = mkOption {
        type = types.str;
        default = "fade";
        description = "SWWW transition type (fade, wipe, grow, etc.)";
      };

      transitionDuration = mkOption {
        type = types.int;
        default = 2;
        description = "SWWW transition duration in seconds";
      };
    };

    theme = {
      enableTerm = mkOption {
        type = types.bool;
        default = true;
        description = "Enable terminal theming (ANSI sequences)";
      };

      enableHypr = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Hyprland theming";
      };

      enableDiscord = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Discord client theming";
      };

      enableSpicetify = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Spicetify theming";
      };

      enableFuzzel = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Fuzzel theming";
      };

      enableBtop = mkOption {
        type = types.bool;
        default = true;
        description = "Enable btop theming";
      };

      enableNvtop = mkOption {
        type = types.bool;
        default = false;
        description = "Enable nvtop theming";
      };

      enableHtop = mkOption {
        type = types.bool;
        default = false;
        description = "Enable htop theming";
      };

      enableWarp = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Warp terminal theming";
      };

      enableCava = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Cava theming";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install required packages based on configuration
    home.packages = with pkgs; [
      # Wallpaper backend
      (mkIf (cfg.wallpaperBackend == "swww") swww)

      # Caelestia packages (from flake inputs)
      # These are already in your flake.nix home.packages
    ];

    # Write Caelestia CLI configuration
    xdg.configFile."caelestia/cli.json" = {
      text = builtins.toJSON cliConfig;
    };

    # Create desktop file for quickshell to fix portal registration
    xdg.dataFile."applications/org.quickshell.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Quickshell
        Comment=Caelestia Shell powered by Quickshell
        Exec=quickshell
        Icon=org.quickshell
        Terminal=false
        Categories=System;
        NoDisplay=true
      '';
    };

    # Create state directory for Caelestia
    home.activation.createCaelestiaState = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${config.home.homeDirectory}/.local/state/caelestia/wallpaper
      mkdir -p ${config.home.homeDirectory}/.cache/caelestia/wallpapers
    '';

    # Set environment variables for icon theme support
    home.sessionVariables = {
      # Ensure QT can find icons
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };

    # Optional: GTK theming via Home Manager (declarative alternative to Caelestia's GTK theming)
    # This uses Home Manager's built-in GTK module instead of writing to read-only directories
    # You can manually set this to match your preferred theme
    gtk = mkIf config.gtk.enable {
      gtk3.extraCss = ''
        /* Caelestia-compatible CSS overrides can go here */
        /* Colors will need to be manually synced or generated from Caelestia's state */
      '';

      gtk4.extraCss = ''
        /* Caelestia-compatible CSS overrides can go here */
      '';
    };
  };
}
