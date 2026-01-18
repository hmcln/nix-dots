{ lib, config, ... }:

with lib;

let
  cfg = config.modules.desktop.hyprland;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # Monitor configuration
      monitor = cfg.monitors ++ [ ",preferred,auto,1" ];

      # Workspace configuration
      workspace = map (ws: "${toString ws.id},monitor:${toString ws.monitor},persistent:${if ws.persistent then "true" else "false"}") cfg.workspaces;

      # Variables
      "$terminal" = cfg.variables.terminal;
      "$browser" = cfg.variables.browser;
      "$editor" = cfg.variables.editor;
      "$fileExplorer" = cfg.variables.fileExplorer;
      "$volumeStep" = toString cfg.variables.volumeStep;
      "$cursorTheme" = cfg.variables.cursorTheme;
      "$cursorSize" = toString cfg.variables.cursorSize;

      # Touchpad variables
      "$touchpadDisableTyping" = cfg.touchpad.disableTyping;
      "$touchpadScrollFactor" = toString cfg.touchpad.scrollFactor;
      "$workspaceSwipeFingers" = toString cfg.gestures.workspaceSwipeFingers;
      "$gestureFingers" = toString cfg.gestures.fingers;
      "$gestureFingersMore" = toString cfg.gestures.fingersMore;

      # Blur variables
      "$blurEnabled" = cfg.blur.enabled;
      "$blurSpecialWs" = cfg.blur.specialWs;
      "$blurPopups" = cfg.blur.popups;
      "$blurInputMethods" = cfg.blur.inputMethods;
      "$blurSize" = toString cfg.blur.size;
      "$blurPasses" = toString cfg.blur.passes;
      "$blurXray" = cfg.blur.xray;

      # Shadow variables
      "$shadowEnabled" = cfg.shadow.enabled;
      "$shadowRange" = toString cfg.shadow.range;
      "$shadowRenderPower" = toString cfg.shadow.renderPower;

      # Gap variables
      "$workspaceGaps" = toString cfg.gaps.workspace;
      "$windowGapsIn" = toString cfg.gaps.windowIn;
      "$windowGapsOut" = toString cfg.gaps.windowOut;
      "$singleWindowGapsOut" = toString cfg.gaps.singleWindowOut;

      # Window variables
      "$windowOpacity" = toString cfg.window.opacity;
      "$windowRounding" = toString cfg.window.rounding;
      "$windowBorderSize" = toString cfg.window.borderSize;

      # Environment variables
      env = [
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "XCURSOR_THEME,$cursorTheme"
        "XCURSOR_SIZE,$cursorSize"
        "GDK_BACKEND,wayland,x11"
        "QT_QPA_PLATFORM,wayland;xcb"
        "SDL_VIDEODRIVER,wayland,x11,windows"
        "CLUTTER_BACKEND,wayland"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "_JAVA_AWT_WM_NONREPARENTING,1"
      ];

      # General settings
      general = {
        layout = "dwindle";
        allow_tearing = false;
        gaps_workspaces = "$workspaceGaps";
        gaps_in = "$windowGapsIn";
        gaps_out = "$windowGapsOut";
        border_size = "$windowBorderSize";
        "col.active_border" = "rgb(7171ac)";
        "col.inactive_border" = "rgb(47464f)";
      };

      dwindle = {
        preserve_split = true;
        smart_split = false;
        smart_resizing = true;
      };

      # Input settings
      input = {
        kb_layout = "us";
        numlock_by_default = false;
        repeat_delay = 250;
        repeat_rate = 35;
        focus_on_close = 1;

        touchpad = {
          natural_scroll = true;
          disable_while_typing = "$touchpadDisableTyping";
          scroll_factor = "$touchpadScrollFactor";
        };
      };

      binds = {
        scroll_event_delay = 0;
      };

      cursor = {
        hotspot_padding = 1;
      };

      # Misc settings
      misc = {
        vfr = true;
        vrr = 1;
        animate_manual_resizes = false;
        animate_mouse_windowdragging = false;
        disable_hyprland_logo = true;
        force_default_wallpaper = 0;
        on_focus_under_fullscreen = 2;
        allow_session_lock_restore = true;
        middle_click_paste = false;
        focus_on_activate = true;
        session_lock_xray = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        background_color = "rgb($surfaceContainer)";
      };

      debug = {
        error_position = 1;
      };

      # Animations
      animations = {
        enabled = true;

        bezier = [
          "specialWorkSwitch, 0.05, 0.7, 0.1, 1"
          "emphasizedAccel, 0.3, 0, 0.8, 0.15"
          "emphasizedDecel, 0.05, 0.7, 0.1, 1"
          "standard, 0.2, 0, 0, 1"
        ];

        animation = [
          "layersIn, 1, 5, emphasizedDecel, slide"
          "layersOut, 1, 4, emphasizedAccel, slide"
          "fadeLayers, 1, 5, standard"
          "windowsIn, 1, 5, emphasizedDecel"
          "windowsOut, 1, 3, emphasizedAccel"
          "windowsMove, 1, 6, standard"
          "workspaces, 1, 5, standard"
          "specialWorkspace, 1, 4, specialWorkSwitch, slidefadevert 15%"
          "fade, 1, 6, standard"
          "fadeDim, 1, 6, standard"
          "border, 1, 6, standard"
        ];
      };

      # Decoration
      decoration = {
        rounding = "$windowRounding";

        blur = {
          enabled = "$blurEnabled";
          xray = "$blurXray";
          special = "$blurSpecialWs";
          ignore_opacity = true;
          new_optimizations = true;
          popups = "$blurPopups";
          input_methods = "$blurInputMethods";
          size = "$blurSize";
          passes = "$blurPasses";
        };

        shadow = {
          enabled = "$shadowEnabled";
          range = "$shadowRange";
          render_power = "$shadowRenderPower";
          color = "rgb(2a292e)";
        };
      };

      # Gestures
      gestures = {
        workspace_swipe_distance = 700;
        workspace_swipe_cancel_ratio = 0.15;
        workspace_swipe_min_speed_to_force = 5;
        workspace_swipe_direction_lock = true;
        workspace_swipe_direction_lock_threshold = 10;
        workspace_swipe_create_new = true;
      };

      gesture = [
        "$workspaceSwipeFingers, horizontal, workspace"
        "$gestureFingers, up, special, special"
        "$gestureFingers, down, dispatcher, exec, caelestia toggle specialws"
        "$gestureFingersMore, down, dispatcher, exec, systemctl suspend-then-hibernate"
      ];

      # Group settings
      group = {
        "col.border_active" = "rgb(7171ac)";
        "col.border_inactive" = "rgb(47464f)";
        "col.border_locked_active" = "rgb(7171ac)";
        "col.border_locked_inactive" = "rgb(47464f)";

        groupbar = {
          font_family = "JetBrains Mono NF";
          font_size = 15;
          gradients = true;
          gradient_round_only_edges = false;
          gradient_rounding = 5;
          height = 25;
          indicator_height = 0;
          gaps_in = 3;
          gaps_out = 3;
          text_color = "rgb(ffffff)";
          "col.active" = "rgb(7171ac)";
          "col.inactive" = "rgb(47464f)";
          "col.locked_active" = "rgb(7171ac)";
          "col.locked_inactive" = "rgb(76758e)";
        };
      };

      # Exec-once commands
      exec-once = [
        "gnome-keyring-daemon --start --components=secrets"
        "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "trash-empty 30"
        "hyprctl setcursor $cursorTheme $cursorSize"
        "gsettings set org.gnome.desktop.interface cursor-theme '$cursorTheme'"
        "gsettings set org.gnome.desktop.interface cursor-size $cursorSize"
        "/usr/lib/geoclue-2.0/demos/agent"
        "sleep 1 && gammastep"
        "mpris-proxy"
        "caelestia resizer -d"
        "caelestia shell -d"
      ];

      # Exec commands
      exec = [
        "hyprctl dispatch submap global"
        "mkdir -p ~/.config/caelestia && touch -a ~/.config/caelestia/hypr-vars.conf"
        "mkdir -p ~/.config/caelestia && touch -a ~/.config/caelestia/hypr-user.conf"
      ];

      # Submap
      submap = "global";
    };

    # Extra configuration from color scheme and user configs
    wayland.windowManager.hyprland.extraConfig = ''
      # Color scheme (managed by Caelestia)
      source = ~/.config/hypr/scheme/current.conf

      # User variables (managed by Caelestia)
      source = ~/.config/caelestia/hypr-vars.conf

      # Apply color scheme to borders and groups (after colors are loaded)
      general {
        col.active_border = rgba($primarye6)
        col.inactive_border = rgba($onSurfaceVariant11)
      }

      group {
        col.border_active = rgba($primarye6)
        col.border_inactive = rgba($onSurfaceVariant11)
        col.border_locked_active = rgba($primarye6)
        col.border_locked_inactive = rgba($onSurfaceVariant11)

        groupbar {
          text_color = rgb($onPrimary)
          col.active = rgba($primaryd4)
          col.inactive = rgba($outlined4)
          col.locked_active = rgba($primaryd4)
          col.locked_inactive = rgba($secondaryd4)
        }
      }

      decoration {
        shadow {
          color = rgba($surfaced4)
        }
      }

      misc {
        background_color = rgb($surfaceContainer)
      }

      # User custom config (managed by Caelestia)
      source = ~/.config/caelestia/hypr-user.conf

      ${cfg.extraConfig}
    '';
  };
}
