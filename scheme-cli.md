# Caelestia CLI Scheme Management - Issues & Improvements

## Current Problems

### Terminal Transparency Issue

The Caelestia CLI applies terminal colors via OSC escape sequences, including:
- `]10;` - foreground color
- `]11;` - background color (problematic)
- `]12;` - cursor color
- `]4;N;` - palette colors 0-18

**The problem:** OSC 11 sets an **opaque** background color. There's no way to specify alpha/transparency in the escape sequence. This means terminals like foot that support transparency lose that transparency when Caelestia applies its theme.

**Current workaround:** We added a `termTransparency` config option that skips the `]11;` sequence. But this means:
1. The terminal falls back to its default background (black), not the theme's background
2. To get the correct background color with transparency, you must hardcode it in the terminal config (e.g., foot's `background` setting)
3. This breaks the dynamic theming - changing Caelestia themes won't update the terminal background

### Architectural Issues

1. **No separation of color data from application:** Colors are generated and immediately applied. There's no intermediate format that other tools can consume.

2. **Terminal-specific features not supported:** Different terminals have different capabilities (transparency, blur, etc.) but the CLI has a one-size-fits-all approach.

3. **No way to query current theme colors:** Other configs (Nix, etc.) can't easily read the current Caelestia color scheme to use in their own configurations.

## Short-Term Fixes

1. **`termTransparency` option** (implemented): Skip OSC 11 when transparency is desired
2. **Hardcode background in terminal config**: Set foot's `background` to the theme color manually, let foot apply alpha to it

## Long-Term Improvements

### 1. Export colors to a consumable format

Write the current color scheme to a well-known location in a parseable format:

```
~/.local/state/caelestia/colors.json
```

Example:
```json
{
  "mode": "dark",
  "surface": "24283b",
  "onSurface": "c0caf5",
  "primary": "7aa2f7",
  "secondary": "7dcfff",
  "tertiary": "bb9af7",
  "term0": "1d202f",
  "term1": "f7768e",
  ...
}
```

This allows:
- Nix configs to read and apply colors at build time (via `caelestia-nix-sync` or similar)
- Other tools to consume the color scheme
- Terminal configs to set background color separately from the escape sequences

### 2. Separate sequence generation from application

Split `gen_sequences()` into:
- `gen_sequences()` - generates all sequences
- `gen_sequences_transparent()` - generates sequences without background
- Or use a more flexible approach with options dict

### 3. Terminal-specific profiles

Allow per-terminal configuration:

```json
{
  "theme": {
    "terminals": {
      "foot": {
        "skipBackground": true,
        "writeConfig": true,
        "configPath": "~/.config/foot/colors.ini"
      },
      "alacritty": {
        "skipBackground": false
      }
    }
  }
}
```

### 4. Generate terminal-native config files

Instead of (or in addition to) escape sequences, generate native config snippets:

- `~/.local/state/caelestia/foot-colors.ini`
- `~/.local/state/caelestia/alacritty-colors.toml`
- `~/.local/state/caelestia/kitty-colors.conf`

These could be `include`d by the main terminal config, allowing the terminal to handle transparency natively while still getting dynamic colors.

### 5. Nix integration module

A proper Nix module that:
- Reads `colors.json` at build time
- Generates terminal configs with correct colors
- Respects terminal-specific settings (alpha, etc.)
- Provides an option like `caelestia.terminals.foot.alpha = 0.78`

## Files Changed (Current Workaround)

- `.tmp/cli/src/caelestia/utils/theme.py` - Added `skip_background` parameter to `gen_sequences()`
- `modules/programs/caelestia.nix` - Added `termTransparency` option
- `hosts/hamish/home.nix` - Enabled `termTransparency = true`
- `modules/programs/foot/default.nix` - Hardcoded `background = "24283b"` for TokyoNight
