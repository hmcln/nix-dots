{ lib, config, ... }:

with lib;

let
  cfg = config.modules.desktop.hyprland;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # Keybind variables
      "$kbMoveWinToWs" = "Super+Shift";
      "$kbMoveWinToWsGroup" = "Ctrl+Super+Alt";
      "$kbGoToWs" = "Super";
      "$kbGoToWsGroup" = "Ctrl+Super";
      "$kbNextWs" = "Ctrl+Super, right";
      "$kbPrevWs" = "Ctrl+Super, left";
      "$kbToggleSpecialWs" = "Super, S";
      "$kbWindowGroupCycleNext" = "Alt, Tab";
      "$kbWindowGroupCyclePrev" = "Shift+Alt, Tab";
      "$kbUngroup" = "Super, U";
      "$kbToggleGroup" = "Super, Comma";
      "$kbMoveWindow" = "Super, Z";
      "$kbResizeWindow" = "Super, X";
      "$kbWindowPip" = "Super+Alt, Backslash";
      "$kbPinWindow" = "Super, P";
      "$kbWindowFullscreen" = "Super, F";
      "$kbWindowBorderedFullscreen" = "Super+Alt, F";
      "$kbToggleWindowFloating" = "Super+Alt, Space";
      "$kbCloseWindow" = "Super, W";
      "$kbSystemMonitor" = "Ctrl+Shift, Escape";
      "$kbMusic" = "Super, M";
      "$kbCommunication" = "Super, D";
      "$kbTodo" = "Super, R";
      "$kbNotes" = "Super, N";
      "$kbTerminal" = "Super, Return";
      "$kbBrowser" = "Super+Shift, Return";
      "$kbEditor" = "Super, C";
      "$kbFileExplorer" = "Super, E";
      "$kbSession" = "Ctrl+Alt, Delete";
      "$kbClearNotifs" = "Ctrl+Alt, C";
      "$kbShowPanels" = "Super+Shift, N";
      "$kbLock" = "Super, Q";
      "$kbRestoreLock" = "Super+Alt, L";
      "$mainMod" = "SUPER";

      # Regular binds
      bind = [
        # Launcher
        "Super, Space, global, caelestia:launcher"
        # Misc
        "$kbSession, global, caelestia:session"
        "$kbShowPanels, global, caelestia:showall"
        "$kbLock, global, caelestia:lock"
        # Workspace switching
        "$kbGoToWs, 1, workspace, 1"
        "$kbGoToWs, 2, workspace, 2"
        "$kbGoToWs, 3, workspace, 3"
        "$kbGoToWs, 4, workspace, 4"
        "$kbGoToWs, 5, workspace, 5"
        "$kbGoToWs, 6, workspace, 6"
        "$kbGoToWs, 7, workspace, 7"
        "$kbGoToWs, 8, workspace, 8"
        "$kbGoToWs, 9, workspace, 9"
        "$kbGoToWs, 0, workspace, 10"
        # Workspace navigation
        "Super, mouse_down, workspace, -1"
        "Super, mouse_up, workspace, +1"
        "$kbToggleSpecialWs, exec, caelestia toggle specialws"
        # Move windows to workspaces
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
        # Move window to/from special workspace
        "Ctrl+Super+Shift, up, movetoworkspace, special:special"
        "Ctrl+Super+Shift, down, movetoworkspace, e+0"
        "Super+Alt, S, movetoworkspace, special:special"
        # Window groups
        "$kbToggleGroup, togglegroup"
        "$kbUngroup, moveoutofgroup"
        "Super+Shift, Comma, lockactivegroup, toggle"
        # Window focus
        "Super, h, movefocus, l"
        "Super, l, movefocus, r"
        "Super, k, movefocus, u"
        "Super, j, movefocus, d"
        # Move windows
        "Super+Shift, h, movewindow, l"
        "Super+Shift, l, movewindow, r"
        "Super+Shift, k, movewindow, u"
        "Super+Shift, j, movewindow, d"
        # Window sizing
        "Ctrl+Super, Backslash, centerwindow, 1"
        "Ctrl+Super+Alt, Backslash, resizeactive, exact 55% 70%"
        "Ctrl+Super+Alt, Backslash, centerwindow, 1"
        "$kbWindowPip, exec, caelestia resizer pip"
        "$kbPinWindow, pin"
        "$kbWindowFullscreen, fullscreen, 0"
        "$kbWindowBorderedFullscreen, fullscreen, 1"
        "$kbToggleWindowFloating, togglefloating,"
        "$kbCloseWindow, killactive,"
        # Special workspace toggles
        "$kbSystemMonitor, exec, caelestia toggle sysmon"
        "$kbMusic, exec, caelestia toggle music"
        "$kbCommunication, exec, caelestia toggle communication"
        "$kbTodo, exec, caelestia toggle todo"
        "$kbNotes, exec, caelestia toggle notes"
        # Apps
        "$kbTerminal, exec, app2unit -- $terminal"
        "$kbBrowser, exec, app2unit -- $browser"
        "$kbEditor, exec, app2unit -- $editor"
        "Super, G, exec, app2unit -- github-desktop"
        "$kbFileExplorer, exec, app2unit -- $fileExplorer"
        "Super+Alt, E, exec, app2unit -- nemo"
        "Ctrl+Alt, Escape, exec, app2unit -- qps"
        "Ctrl+Alt, V, exec, app2unit -- pavucontrol"
        # Utilities
        "Super+Shift, P, exec, caelestia screenshot"
        "Super+Shift, O, exec, caelestia screenshot -r"
        "Super+Shift, S, global, caelestia:screenshotFreeze"
        "Super+Shift+Alt, S, global, caelestia:screenshot"
        "Super+Alt, R, exec, caelestia record -s"
        "Ctrl+Alt, R, exec, caelestia record"
        "Super+Shift+Alt, R, exec, caelestia record -r"
        "Super+Shift, C, exec, hyprpicker -a"
        # Clipboard and emoji
        "Super, V, exec, pkill fuzzel || caelestia clipboard"
        "Super+Alt, V, exec, pkill fuzzel || caelestia clipboard -d"
        "Super, Period, exec, pkill fuzzel || caelestia emoji -p"
        # Manual workspace moves
        "Super, comma, movecurrentworkspacetomonitor, l"
        "Super, period, movecurrentworkspacetomonitor, r"
        # Workspace navigation (mouse)
        "Ctrl+Super, mouse_down, workspace, -10"
        "Ctrl+Super, mouse_up, workspace, +10"
        # Move window workspace navigation
        "Super+Alt, mouse_down, movetoworkspace, -1"
        "Super+Alt, mouse_up, movetoworkspace, +1"
      ];

      # Repeat binds
      binde = [
        "$kbPrevWs, workspace, -1"
        "$kbNextWs, workspace, +1"
        "Super, Page_Up, workspace, -1"
        "Super, Page_Down, workspace, +1"
        "Super+Alt, Page_Up, movetoworkspace, -1"
        "Super+Alt, Page_Down, movetoworkspace, +1"
        "Ctrl+Super+Shift, right, movetoworkspace, +1"
        "Ctrl+Super+Shift, left, movetoworkspace, -1"
        "$kbWindowGroupCycleNext, cyclenext, activewindow"
        "$kbWindowGroupCycleNext, cyclenext, prev, activewindow"
        "Ctrl+Alt, Tab, changegroupactive, f"
        "Ctrl+Shift+Alt, Tab, changegroupactive, b"
        "Super, Minus, splitratio, -0.1"
        "Super, Equal, splitratio, 0.1"
      ];

      # Mouse binds
      bindm = [
        "Super, mouse:272, movewindow"
        "$kbMoveWindow, movewindow"
        "Super, mouse:273, resizewindow"
        "$kbResizeWindow, resizewindow"
      ];

      # Locked binds (work even when locked)
      bindl = [
        "$kbClearNotifs, global, caelestia:clearNotifs"
        "$kbRestoreLock, exec, caelestia shell -d"
        "$kbRestoreLock, global, caelestia:lock"
        ", XF86MonBrightnessUp, global, caelestia:brightnessUp"
        ", XF86MonBrightnessDown, global, caelestia:brightnessDown"
        "Ctrl+Super, Space, global, caelestia:mediaToggle"
        ", XF86AudioPlay, global, caelestia:mediaToggle"
        ", XF86AudioPause, global, caelestia:mediaToggle"
        "Ctrl+Super, Equal, global, caelestia:mediaNext"
        ", XF86AudioNext, global, caelestia:mediaNext"
        "Ctrl+Super, Minus, global, caelestia:mediaPrev"
        ", XF86AudioPrev, global, caelestia:mediaPrev"
        ", XF86AudioStop, global, caelestia:mediaStop"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "Super+Shift, M, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "Ctrl+Shift+Alt, V, exec, sleep 0.5s && ydotool type -d 1 \"$(cliphist list | head -1 | cliphist decode)\""
        "Super+Alt, f12, exec, notify-send -u low -i dialog-information-symbolic 'Test notification' \"Here's a really long message to test truncation and wrapping\\nYou can middle click or flick this notification to dismiss it!\" -a 'Shell' -A \"Test1=I got it!\" -A \"Test2=Another action\""
      ];

      # Repeat locked binds
      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ $volumeStep%+"
        ", XF86AudioLowerVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ $volumeStep%-"
      ];

      # Release binds
      bindr = [
        "Ctrl+Super+Shift, R, exec, qs -c caelestia kill"
        "Ctrl+Super+Alt, R, exec, qs -c caelestia kill; caelestia shell -d"
      ];

      # Launcher interrupt binds
      bindin = [
        "Super, mouse:272, global, caelestia:launcherInterrupt"
        "Super, mouse:273, global, caelestia:launcherInterrupt"
        "Super, mouse:274, global, caelestia:launcherInterrupt"
        "Super, mouse:275, global, caelestia:launcherInterrupt"
        "Super, mouse:276, global, caelestia:launcherInterrupt"
        "Super, mouse:277, global, caelestia:launcherInterrupt"
        "Super, mouse_up, global, caelestia:launcherInterrupt"
        "Super, mouse_down, global, caelestia:launcherInterrupt"
      ];
    };
  };
}
