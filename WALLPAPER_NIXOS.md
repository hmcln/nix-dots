# Wallpaper Subcommand on NixOS

## How the Wallpaper Subcommand Works

The `caelestia wallpaper` subcommand is a sophisticated theming system that automatically generates color schemes from wallpapers and applies them across your entire desktop environment.

### Current Implementation

The wallpaper system performs the following operations:

1. **Image Processing** (src/caelestia/utils/wallpaper.py:125-171)
   - Validates the image file format (JPG, PNG, WebP, TIF)
   - Creates an absolute path to the wallpaper
   - Generates a SHA256 hash of the image for caching

2. **File System Operations**
   - Writes wallpaper path to: `$XDG_STATE_HOME/caelestia/wallpaper/path.txt`
   - Creates symlink at: `$XDG_STATE_HOME/caelestia/wallpaper/current` → wallpaper file
   - Generates 128x128 thumbnail cached at: `$XDG_CACHE_HOME/caelestia/wallpapers/{hash}/thumbnail.jpg`
   - Links thumbnail to: `$XDG_STATE_HOME/caelestia/wallpaper/thumbnail.jpg`

3. **Smart Color Analysis** (src/caelestia/utils/wallpaper.py:72-95)
   - Analyzes image colourfulness to determine variant (tonalspot, vibrant, expressive, etc.)
   - Samples 1x1 resized image to get average tone
   - Determines light/dark mode based on image brightness (threshold: tone > 60)
   - Caches results in: `$XDG_CACHE_HOME/caelestia/wallpapers/{hash}/smart.json`

4. **Material You Color Generation** (src/caelestia/utils/material/*)
   - Uses Material You color algorithm to extract primary colors
   - Generates complete color palette based on the scheme variant
   - Updates the active scheme with new colors

5. **Theme Application** (src/caelestia/utils/theme.py:237-271)
   - Writes configuration files to `$XDG_CONFIG_HOME` for multiple applications:
     - **GTK 3/4**: `~/.config/gtk-{3,4}.0/gtk.css` ← **FAILS ON NIXOS**
     - **Hyprland**: `~/.config/hypr/scheme/current.conf`
     - **Qt5/6**: `~/.config/qt{5,6}ct/colors/caelestia.colors`
     - **Discord clients**: Equicord, Vencord, BetterDiscord, etc.
     - **Terminal apps**: btop, htop, nvtop, cava
     - **Other**: Fuzzel, Spicetify, Warp Terminal
   - Writes ANSI escape sequences to `/dev/pts/*` for terminal recoloring
   - Runs `dconf write` commands to update GTK/GNOME settings ← **FAILS ON NIXOS**

6. **Post-Hook Execution** (src/caelestia/utils/wallpaper.py:159-170)
   - Reads config from: `$XDG_CONFIG_HOME/caelestia/cli.json`
   - Executes custom shell command with `$WALLPAPER_PATH` environment variable
   - Allows custom wallpaper-setting backends (swww, hyprpaper, swaybg, etc.)

### Why It Fails on NixOS

The primary issues on NixOS are:

1. **Read-only GTK directories**: GTK theme files installed via Nix are in `/nix/store/...` which is immutable
2. **dconf schema validation**: The GTK theme names referenced may not exist in the Nix-installed GTK packages
3. **Application config isolation**: NixOS applications may look for configs in different locations
4. **File permissions**: Some operations assume traditional Linux filesystem permissions

## NixOS-Compatible Alternatives

### Option 1: Home Manager Integration (Recommended)

Create a NixOS/Home Manager module that hooks into the wallpaper system without modifying read-only directories.

**Implementation approach:**

```nix
# ~/.config/home-manager/modules/caelestia-wallpaper.nix
{ config, lib, pkgs, ... }:

let
  caelestiaWallpaperHook = pkgs.writeShellScript "caelestia-wallpaper-hook" ''
    #!/usr/bin/env bash

    # Read the color scheme from caelestia's state
    SCHEME_FILE="$XDG_STATE_HOME/caelestia/scheme.json"

    if [ -f "$SCHEME_FILE" ]; then
      # Extract colors and write to a file that Home Manager can read
      ${pkgs.jq}/bin/jq -r '.colours' "$SCHEME_FILE" > "$XDG_STATE_HOME/caelestia/colours-for-hm.json"

      # Trigger Home Manager rebuild (if configured for auto-reload)
      # Or just update the symlinks manually

      # Set wallpaper using your preferred backend
      ${pkgs.swww}/bin/swww img "$WALLPAPER_PATH" --transition-type fade
    fi
  '';
in
{
  home.file.".config/caelestia/cli.json".text = builtins.toJSON {
    wallpaper.postHook = toString caelestiaWallpaperHook;
    theme = {
      enableGtk = false;  # Disable GTK file writing
      enableQt = true;
      enableHypr = true;
      enableTerm = true;
      # ... other settings
    };
  };

  # Use Home Manager's GTK theming instead
  gtk = {
    enable = true;
    theme.name = "adw-gtk3-dark";
    gtk3.extraCss = builtins.readFile (
      # Read colors from caelestia and generate CSS
      # This would need a derivation that reads the current scheme
    );
  };
}
```

### Option 2: Declarative Color Scheme Updater

Create a separate tool that reads Caelestia's generated colors and updates NixOS configuration.

**Create a new script:**

```bash
#!/usr/bin/env bash
# ~/.local/bin/caelestia-nix-sync

SCHEME_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json"
COLORS_NIX="$HOME/.config/home-manager/caelestia-colors.nix"

if [ ! -f "$SCHEME_FILE" ]; then
  echo "No caelestia scheme found"
  exit 1
fi

# Extract colors and convert to Nix attribute set
cat > "$COLORS_NIX" << EOF
{
  colours = {
$(jq -r '.colours | to_entries | .[] | "    \(.key) = \"\(.value)\";"' "$SCHEME_FILE")
  };
  mode = "$(jq -r '.mode' "$SCHEME_FILE")";
}
EOF

echo "Colors synced to $COLORS_NIX"
echo "Run 'home-manager switch' to apply"
```

**Add to your wallpaper post-hook:**

```json
{
  "wallpaper": {
    "postHook": "swww img \"$WALLPAPER_PATH\" && ~/.local/bin/caelestia-nix-sync"
  },
  "theme": {
    "enableGtk": false,
    "enableQt": false
  }
}
```

### Option 3: Runtime-Only Theming

Disable file-based theming and use only runtime methods that don't require writing to read-only directories.

**Configure Caelestia to skip file operations:**

```json
{
  "theme": {
    "enableTerm": true,      // ANSI sequences to /dev/pts - works fine
    "enableHypr": true,      // Hyprland config - works if writable
    "enableGtk": false,      // Skip GTK - fails on NixOS
    "enableQt": false,       // Skip Qt - fails on NixOS
    "enableDiscord": true,   // User config dir - works
    "enableSpicetify": true, // User config dir - works
    "enableFuzzel": true,    // User config dir - works
    "enableBtop": true,      // User config dir - works
    "enableNvtop": true,     // User config dir - works
    "enableHtop": true,      // User config dir - works
    "enableWarp": true,      // User config dir - works
    "enableCava": true       // User config dir - works
  }
}
```

**Use GTK CSS loading from XDG_CONFIG_HOME:**

GTK does support loading user CSS from `~/.config/gtk-{3,4}.0/gtk.css`, so the current implementation should work. If it's failing, ensure:

```bash
# Check if the directory is writable
ls -ld ~/.config/gtk-3.0
ls -ld ~/.config/gtk-4.0

# These should NOT be symlinks to /nix/store
# If they are, remove them:
rm -rf ~/.config/gtk-3.0 ~/.config/gtk-4.0
mkdir -p ~/.config/gtk-{3,4}.0
```

### Option 4: Custom User Templates

Use Caelestia's user templates feature to generate theme files without touching system directories.

**Create custom templates:**

```bash
mkdir -p ~/.config/caelestia/templates

# Create a template that outputs to a safe location
cat > ~/.config/caelestia/templates/my-theme.css << 'EOF'
/* Custom theme file */
:root {
  --primary: {{ $primary }};
  --secondary: {{ $secondary }};
  --background: {{ $surface }};
  --foreground: {{ $onSurface }};
}
EOF
```

These templates will be processed and output to `$XDG_STATE_HOME/caelestia/theme/` (src/caelestia/utils/theme.py:226-234).

### Option 5: Wrapper Script with Selective Operations

Create a wrapper that calls Caelestia wallpaper functions but only performs NixOS-safe operations.

```python
#!/usr/bin/env python3
# ~/.local/bin/caelestia-wallpaper-nix

import sys
from pathlib import Path
from caelestia.utils.wallpaper import get_colours_for_wall, set_wallpaper
from caelestia.utils.theme import apply_terms, apply_hypr, gen_sequences, gen_conf
import subprocess
import json

def safe_set_wallpaper(wall_path: str):
    """Set wallpaper on NixOS safely"""
    wall = Path(wall_path).resolve()

    # Get colors from wallpaper
    colors = get_colours_for_wall(wall, no_smart=False)

    # Apply only safe theme operations
    apply_terms(gen_sequences(colors['colours']))
    apply_hypr(gen_conf(colors['colours']))

    # Use swww or hyprpaper to set wallpaper
    subprocess.run(['swww', 'img', str(wall), '--transition-type', 'fade'])

    print(f"Wallpaper set: {wall}")
    print(f"Mode: {colors['mode']}, Variant: {colors['variant']}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: caelestia-wallpaper-nix <image-path>")
        sys.exit(1)

    safe_set_wallpaper(sys.argv[1])
```

## Recommended Solution

For most NixOS users, I recommend **Option 1 (Home Manager Integration)** combined with **Option 3 (Runtime-Only Theming)**:

1. **Disable GTK/Qt file writing** in `cli.json` to avoid read-only filesystem errors
2. **Use the postHook** to call `swww` or `hyprpaper` for wallpaper display
3. **Keep terminal theming enabled** (ANSI sequences work fine)
4. **Use Home Manager** to manage GTK/Qt themes declaratively, importing colors from Caelestia's state files if needed
5. **Keep user-writable configs enabled** (Discord, btop, Hyprland, etc.)

This approach maintains the Material You color generation and smart theming while working within NixOS's constraints.

## Example Configuration

```json
{
  "wallpaper": {
    "postHook": "swww img \"$WALLPAPER_PATH\" --transition-type fade --transition-duration 2"
  },
  "theme": {
    "enableTerm": true,
    "enableHypr": true,
    "enableGtk": false,
    "enableQt": false,
    "enableDiscord": true,
    "enableSpicetify": true,
    "enableFuzzel": true,
    "enableBtop": true,
    "enableNvtop": true,
    "enableHtop": true,
    "enableWarp": true,
    "enableCava": true
  }
}
```

Then use Caelestia normally:

```bash
caelestia wallpaper /path/to/wallpaper.png
caelestia wallpaper --random ~/Pictures/Wallpapers
```

The color scheme will still be generated and applied to supported applications, but GTK/Qt will be managed through NixOS configuration instead.
