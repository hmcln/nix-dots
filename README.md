# NixOS Configuration

Home-manager based NixOS configuration inspired by ~/dots/nixos.

## Quick Start

### Rebuild Configurations

**Recommended: Home Manager Only (No sudo required, fast)**
```bash
# Using make (recommended)
make home

# Or using home-manager directly
home-manager switch --flake .#hamish

# Or using the helper script
./rebuild.sh home
```

**System Configuration (Requires sudo)**
```bash
# Using make
make system

# Or using nixos-rebuild directly
sudo nixos-rebuild switch --flake .#thinkpad-x9

# Or using the helper script
./rebuild.sh system
```

**Rebuild Everything**
```bash
make all
```

**Other Commands**
```bash
make check    # Check flake for errors
make update   # Update flake inputs
make clean    # Clean old generations
make help     # Show all available commands
```

### Update Flake Inputs

```bash
nix flake update
# or
make update
```

### Update Specific Input

```bash
nix flake lock --update-input nixpkgs
nix flake lock --update-input caelestia-shell
```

## Structure

```
~/nix-dots/
├── flake.nix              # Main flake configuration
├── configuration.nix      # Shared NixOS system configuration
├── hosts/                 # Host-specific configurations
│   └── thinkpad-x9/       # Configuration for this machine
│       ├── default.nix    # Host-specific settings
│       └── hardware-configuration.nix  # Auto-generated hardware config
├── modules/
│   ├── default.nix        # Module loader
│   ├── programs/          # Program-specific modules
│   │   ├── default.nix    # Program options and imports
│   │   ├── neovim.nix     # Neovim configuration
│   │   ├── btop.nix       # btop system monitor
│   │   ├── foot.nix       # Foot terminal
│   │   ├── lazygit.nix    # Lazygit TUI
│   │   ├── caelestia.nix  # Caelestia theming system
│   │   └── caelestia-sync.nix  # Color sync utility
│   ├── desktop/
│   │   └── services/
│   │       └── default.nix  # Desktop services (darkman, etc.)
│   └── persistence.nix    # Persistence and backup settings
└── CAELESTIA_SETUP.md     # Caelestia integration guide
```

## Modules

All modules use the `modules.programs.<name>.enable` pattern.

### Enabled Modules

Currently enabled in `flake.nix`:

- **neovim** - Text editor with LSP, formatters, and plugins
- **btop** - System monitor with custom caelestia theme
- **foot** - Terminal emulator
- **lazygit** - Git TUI with shell aliases
- **caelestia** - Wallpaper and theming system

### Module Options

Each module can be configured in `flake.nix`. Example:

```nix
modules.programs.neovim.enable = true;

modules.programs.caelestia = {
  enable = true;
  wallpaperBackend = "swww";
  theme.enableBtop = true;
};
```

## Configuration Approach

This setup uses a **fully declarative Nix configuration**:

- **All configurations are defined in Nix modules** under `modules/`
- **No symlinks to external dotfiles** (previous approach removed)
- **Two rebuild options:**
  - **Home Manager** (user-level, no sudo) - for most changes
  - **NixOS System** (system-level, requires sudo) - for kernel, services, etc.

### Dual Configuration Outputs

The flake provides two configurations:

1. **`homeConfigurations.hamish`** - Standalone home-manager (rebuild without sudo)
2. **`nixosConfigurations.thinkpad-x9`** - Full system config (includes home-manager)

Both configurations are kept in sync and share the same module definitions.

## Adding New Programs

1. Create module file in `modules/programs/`:

```nix

# modules/programs/myapp.nix

{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.modules.programs.myapp;
in
{
  config = mkIf cfg.enable {
    home.packages = [ pkgs.myapp ];

    # Link to dotfiles config
    xdg.configFile."myapp/config".source =
      config.lib.file.mkOutOfStoreSymlink "/home/hamish/dotfiles/myapp/config";
  };
}
```

2. Add to `modules/programs/default.nix`:

```nix
imports = [
  ./myapp.nix
];

options.modules.programs.myapp = {
  enable = mkEnableOption "My Application";
};
```

3. Enable in `flake.nix`:

```nix
modules.programs.myapp.enable = true;
```

4. Rebuild:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## Theming

See [CAELESTIA_SETUP.md](./CAELESTIA_SETUP.md) for detailed Caelestia integration.

Quick theming workflow:
```bash

# Set wallpaper and generate theme

caelestia wallpaper ~/Pictures/wallpaper.png

# Optional: sync colors to Nix

caelestia-nix-sync
```

## Hosts

This configuration supports multiple hosts using the `hosts/` directory pattern.

### Current Host: thinkpad-x9

Each host has its own directory containing:
- `default.nix` - Host-specific settings (hostname, hardware tweaks, etc.)
- `hardware-configuration.nix` - Auto-generated hardware config (committed to git)

### Adding a New Host

1. Create host directory:
```bash
mkdir -p hosts/my-machine
```

2. Copy hardware configuration:
```bash
sudo cp /etc/nixos/hardware-configuration.nix hosts/my-machine/
```

3. Create `hosts/my-machine/default.nix`:
```nix
{ config, lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "my-machine";
  # Add host-specific config here
}
```

4. Add to `flake.nix`:
```nix
nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ./configuration.nix
    ./hosts/my-machine
    home-manager.nixosModules.home-manager
    # ... rest of config
  ];
};
```

5. Rebuild:
```bash
sudo nixos-rebuild switch --flake .#my-machine
```

## Flakes

This configuration uses **Nix flakes** for:

- **Reproducibility** - Exact version pinning via `flake.lock`
- **Composability** - Importing other flakes (caelestia-shell, caelestia-cli)
- **Better UX** - Clear `inputs` and `outputs` structure

### Flake Inputs

- `nixpkgs` - Main package repository
- `home-manager` - User environment manager
- `caelestia-shell` - Hyprland shell environment
- `caelestia-cli` - Caelestia theming CLI

## Tips

### Dry Run Rebuild

```bash
nixos-rebuild dry-activate --flake .#nixos
```

### Check Flake

```bash
nix flake check
```

### Show Flake Outputs

```bash
nix flake show
```

### Garbage Collection

```bash

# Delete old generations

sudo nix-collect-garbage -d

# Keep last N generations

sudo nix-collect-garbage --delete-older-than 7d
```

### Search Packages

```bash
nix search nixpkgs <package-name>
```

## References

- Inspiration: ~/dots/nixos (JManch's dotfiles)
- Home Manager: <https://nix-community.github.io/home-manager/>
- NixOS Wiki: <https://nixos.wiki/>
- Caelestia: <https://github.com/caelestia-dots/>
