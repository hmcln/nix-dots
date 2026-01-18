.PHONY: help home system all check update clean

help:
	@echo "NixOS Configuration Management"
	@echo ""
	@echo "Available targets:"
	@echo "  make home    - Rebuild home-manager only (no sudo, fast)"
	@echo "  make system  - Rebuild NixOS system (requires sudo)"
	@echo "  make all     - Rebuild both system and home-manager"
	@echo "  make check   - Check flake for errors"
	@echo "  make update  - Update flake inputs"
	@echo "  make clean   - Clean old generations"
	@echo ""
	@echo "Default: make home"

# Default target
.DEFAULT_GOAL := home

# Rebuild home-manager (no sudo required)
home:
	@echo "🏠 Rebuilding Home Manager configuration..."
	@if command -v home-manager >/dev/null 2>&1; then \
		home-manager switch --flake .#hamish; \
	else \
		echo "ℹ️  home-manager not in PATH yet, using nix run..."; \
		nix run home-manager/master -- switch --flake .#hamish; \
	fi
	@echo "✅ Home Manager rebuild complete!"

# Rebuild system (requires sudo)
system:
	@echo "🖥️  Rebuilding NixOS system configuration..."
	sudo nixos-rebuild switch --flake .#thinkpad-x9
	@echo "✅ System rebuild complete!"

# Rebuild both
all: system home

# Check flake
check:
	@echo "🔍 Checking flake configuration..."
	nix flake check

# Update flake inputs
update:
	@echo "📦 Updating flake inputs..."
	nix flake update

# Clean old generations
clean:
	@echo "🧹 Cleaning old generations..."
	@echo "Home Manager generations:"
	home-manager expire-generations "-7 days"
	@echo ""
	@echo "System generations (requires sudo):"
	sudo nix-collect-garbage --delete-older-than 7d
	@echo "✅ Cleanup complete!"
