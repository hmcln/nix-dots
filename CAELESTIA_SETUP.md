# Caelestia Integration for NixOS

This configuration integrates the Caelestia wallpaper and theming system with NixOS home-manager, following the recommendations from `WALLPAPER_NIXOS.md`.

## Overview

The Caelestia module (`modules/programs/caelestia.nix`) provides:
- NixOS-compatible wallpaper backend configuration (swww or hyprpaper)
- Automatic CLI configuration that disables GTK/Qt file writing
- Enables theming for user-writable configs (Discord, Hyprland, btop, terminals, etc.)
- Optional color sync script for future declarative theming

## What's Configured

### Enabled (Works on NixOS)
- ✅ **Terminal theming** - ANSI escape sequences
- ✅ **Hyprland theming** - Config file generation
- ✅ **Discord theming** - Equicord, Vencord, BetterDiscord
- ✅ **btop theming** - Color scheme generation
- ✅ **Fuzzel theming** - Launcher colors
- ✅ **Wallpaper backend** - swww with customizable transitions

### Disabled (Fails on NixOS)
- ❌ **GTK theming** - Read-only /nix/store paths
- ❌ **Qt theming** - Read-only /nix/store paths

These are managed declaratively via Home Manager's `gtk` and `qt` options instead.

## Configuration

The module is enabled in `flake.nix`:

\`\`\`nix
modules.programs.caelestia = {
  enable = true;
  wallpaperBackend = "swww";  # or "hyprpaper"

  swww = {
    transitionType = "fade";
    transitionDuration = 2;
  };

  theme = {
    enableTerm = true;      # Terminal ANSI theming
    enableHypr = true;      # Hyprland theming
    enableDiscord = true;   # Discord client theming
    enableFuzzel = true;    # Fuzzel launcher theming
    enableBtop = true;      # btop theming
    enableSpicetify = false; # Spotify theming (if you use it)
    enableCava = false;     # Audio visualizer theming
    # ... other options
  };
};
\`\`\`

## Generated Files

The module automatically creates `~/.config/caelestia/cli.json` with:

\`\`\`json
{
  "wallpaper": {
    "postHook": "/nix/store/.../caelestia-wallpaper-hook"
  },
  "theme": {
    "enableTerm": true,
    "enableHypr": true,
    "enableDiscord": true,
    "enableGtk": false,
    "enableQt": false,
    ...
  }
}
\`\`\`

## Usage

### Setting a Wallpaper

\`\`\`bash
# Set a specific wallpaper
caelestia wallpaper ~/Pictures/wallpaper.png

# Random wallpaper from directory
caelestia wallpaper --random ~/Pictures/Wallpapers

# Random with specific mode
caelestia wallpaper --random ~/Pictures/Wallpapers --mode dark
\`\`\`

The module's post-hook will automatically:
1. Set the wallpaper using swww (or your configured backend)
2. Generate Material You color scheme from the image
3. Apply colors to enabled applications

### Checking Current Theme

\`\`\`bash
# View current color scheme
cat ~/.local/state/caelestia/scheme.json | jq

# View current wallpaper path
cat ~/.local/state/caelestia/wallpaper/path.txt
\`\`\`

## Optional: Color Sync to Nix

The `caelestia-nix-sync` command is available to export colors for declarative theming:

\`\`\`bash
# Export current Caelestia colors to Nix format
caelestia-nix-sync

# This creates ~/.config/nixos/caelestia-colors.nix
\`\`\`

You can then import this file in your Nix modules for declarative color theming:

\`\`\`nix
# In a module
let
  caelestiaColors = import ~/.config/nixos/caelestia-colors.nix;
in {
  gtk.gtk3.extraCss = ''
    * {
      background-color: #''${caelestiaColors.colours.surface};
      color: #''${caelestiaColors.colours.onSurface};
    }
  '';
}
\`\`\`

## Customization

### Change Wallpaper Backend

Edit `flake.nix`:

\`\`\`nix
modules.programs.caelestia.wallpaperBackend = "hyprpaper";
\`\`\`

Then rebuild:

\`\`\`bash
sudo nixos-rebuild switch
\`\`\`

### Customize SWWW Transitions

\`\`\`nix
modules.programs.caelestia.swww = {
  transitionType = "wipe";  # fade, wipe, grow, center, any, outer
  transitionDuration = 3;    # seconds
};
\`\`\`

### Enable/Disable Theming for Specific Apps

\`\`\`nix
modules.programs.caelestia.theme = {
  enableSpicetify = true;   # Enable Spotify theming
  enableCava = true;        # Enable audio visualizer theming
  enableBtop = false;       # Disable btop theming (use manual config)
};
\`\`\`

## GTK/Qt Theming (Manual)

Since GTK/Qt theming is disabled to avoid NixOS compatibility issues, you can set up declarative theming via Home Manager:

\`\`\`nix
# In your home-manager configuration
gtk = {
  enable = true;
  theme.name = "Adwaita-dark";  # or your preferred theme

  gtk3.extraCss = ''
    /* Custom CSS based on Caelestia colors if desired */
  '';
};

qt = {
  enable = true;
  platformTheme = "gtk";
};
\`\`\`

## Troubleshooting

### Wallpaper not changing

Check if swww is running:
\`\`\`bash
swww query
# If not running:
swww-daemon &
\`\`\`

### Colors not applying to terminals

The terminal you're using must support ANSI escape sequences. Check:
\`\`\`bash
echo -e "\\033[31mRed text\\033[0m"
\`\`\`

### btop colors not matching

If btop theming is enabled in Caelestia, it may conflict with the btop module's static theme. Either:
1. Disable `modules.programs.caelestia.theme.enableBtop = false;`
2. Or remove the static theme from `modules/programs/btop.nix`

## Integration with Existing Dotfiles

Your dotfiles (`~/dotfiles`) are still the primary source for configurations:
- btop theme: `~/dotfiles/btop/themes/caelestia.theme`
- Caelestia will write dynamic themes to `~/.config/btop/themes/` based on wallpaper
- Both can coexist - use `color_theme = "caelestia"` in btop to use static, or let Caelestia override it

## References

- Caelestia Shell: https://github.com/caelestia-dots/shell
- Caelestia CLI: https://github.com/caelestia-dots/cli
- SWWW: https://github.com/LGFae/swww
- See `WALLPAPER_NIXOS.md` for detailed technical information
