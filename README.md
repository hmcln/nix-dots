# NixOS Configuration

Declarative NixOS + Home Manager configuration using Nix flakes.

## Rebuilding

There are two rebuild commands. Both must be run from the flake directory (`~/nix-dots`).

**System rebuild** (NixOS + home-manager, requires sudo, creates a new boot generation):
```bash
sudo nixos-rebuild switch --flake .#thinkpad-x9
```

**Home-manager only** (user-level, no sudo, fast — use for most day-to-day changes):
```bash
home-manager switch -b hm-bak --flake .#hamish
```

The `-b hm-bak` flag backs up any existing files that would conflict.

Both targets share the same `hosts/hamish/home.nix`, so there's no config drift — just two entry points to the same modules.

## Boot generations

Every `sudo nixos-rebuild switch` creates a new NixOS system generation, which appears as an entry in the boot menu. These accumulate over time.

**List generations:**
```bash
nix-env --list-generations --profile /nix/var/nix/profiles/system
```

**Clean old generations:**
```bash
sudo nix-collect-garbage --delete-older-than 30d
```

**Update boot menu** (after cleaning, to remove stale entries):
```bash
sudo nixos-rebuild switch --flake .#thinkpad-x9
```

## Flake management

```bash
# Update all inputs
nix flake update

# Update a single input
nix flake update nixpkgs
nix flake update caelestia-shell

# Check flake for errors
nix flake check

# Show flake outputs
nix flake show

# Dry-run rebuild (see what would change)
nixos-rebuild dry-activate --flake .#thinkpad-x9

# Search packages
nix search nixpkgs <package-name>
```

## Directory structure

```
~/nix-dots/
├── flake.nix                       # Flake inputs, outputs, and host definitions
├── flake.lock                      # Pinned input versions
├── configuration.nix               # Shared NixOS system configuration
├── hosts/
│   ├── hamish/
│   │   └── home.nix                # Home Manager config (shared by all hosts)
│   ├── thinkpad-x9/
│   │   ├── default.nix             # Host-specific NixOS settings
│   │   └── hardware-configuration.nix
│   └── wsl/
│       └── default.nix             # WSL-specific NixOS settings
├── modules/
│   ├── default.nix                 # Module loader
│   ├── persistence.nix             # Persistence and backup settings
│   ├── programs/
│   │   ├── default.nix             # Program options and imports
│   │   ├── neovim.nix              # Neovim (LazyVim)
│   │   ├── btop/                   # btop + caelestia theme
│   │   ├── fish/                   # Fish shell + custom functions
│   │   ├── foot/                   # Foot terminal
│   │   ├── lazygit/                # Lazygit TUI
│   │   ├── starship/               # Starship prompt
│   │   ├── tmux/                   # tmux
│   │   ├── caelestia.nix           # Caelestia wallpaper/theming
│   │   └── caelestia-sync.nix      # Caelestia color sync
│   └── desktop/
│       ├── default.nix             # Desktop module loader
│       ├── cursor.nix              # Cursor theme
│       ├── hyprland/               # Hyprland compositor config
│       └── services/               # Desktop services (darkman, etc.)
└── CAELESTIA_SETUP.md              # Caelestia integration guide
```

## Adding new programs

1. Create a module file in `modules/programs/`:

```nix
# modules/programs/myapp.nix
{ lib, config, pkgs, ... }:

let
  cfg = config.modules.programs.myapp;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.myapp ];
  };
}
```

2. Add to `modules/programs/default.nix`:

```nix
imports = [
  ./myapp.nix
];

options.modules.programs.myapp = {
  enable = lib.mkEnableOption "My Application";
};
```

3. Enable in `hosts/hamish/home.nix`:

```nix
modules.programs.myapp.enable = true;
```

4. Rebuild:

```bash
home-manager switch -b hm-bak --flake .#hamish
```

## Hosts

| Host | Target | Description |
|------|--------|-------------|
| thinkpad-x9 | `nixosConfigurations.thinkpad-x9` | Primary machine — full NixOS + Hyprland desktop |
| wsl | `nixosConfigurations.wsl` | WSL — CLI-only modules, no desktop |
| hamish | `homeConfigurations.hamish` | Standalone home-manager (no sudo, fast rebuilds) |

The `hamish` home-manager config and the `thinkpad-x9` NixOS config both import `hosts/hamish/home.nix`, so they stay in sync.

## References

- [Home Manager manual](https://nix-community.github.io/home-manager/)
- [NixOS Wiki](https://nixos.wiki/)
- [Caelestia](https://github.com/caelestia-dots/)
- [CAELESTIA_SETUP.md](./CAELESTIA_SETUP.md) — Caelestia integration guide
