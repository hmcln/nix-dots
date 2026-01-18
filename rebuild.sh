#!/usr/bin/env bash
# Helper script for rebuilding configurations

set -euo pipefail

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Rebuild your NixOS and Home Manager configurations.

OPTIONS:
    hm, home          Rebuild home-manager only (no sudo required)
    sys, system       Rebuild NixOS system configuration (requires sudo)
    all, both         Rebuild both system and home-manager (requires sudo)
    -h, --help        Show this help message

EXAMPLES:
    $(basename "$0") hm       # Fast, sudo-free rebuild of user config
    $(basename "$0") sys      # System-only rebuild
    $(basename "$0") all      # Full rebuild of everything

If no option is provided, defaults to home-manager only.
EOF
}

rebuild_home() {
    echo "🏠 Rebuilding Home Manager configuration..."
    if command -v home-manager >/dev/null 2>&1; then
        home-manager switch --flake .#hamish
    else
        echo "ℹ️  home-manager not in PATH yet, using nix run..."
        nix run home-manager/master -- switch --flake .#hamish
    fi
    echo "✅ Home Manager rebuild complete!"
}

rebuild_system() {
    echo "🖥️  Rebuilding NixOS system configuration..."
    sudo nixos-rebuild switch --flake .#thinkpad-x9
    echo "✅ System rebuild complete!"
}

rebuild_all() {
    rebuild_system
    rebuild_home
}

# Parse arguments
case "${1:-hm}" in
    hm|home)
        rebuild_home
        ;;
    sys|system)
        rebuild_system
        ;;
    all|both)
        rebuild_all
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo "❌ Unknown option: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
