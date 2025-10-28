{
  description = "Hamish NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-cli = {
      url = "github:caelestia-dots/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url ="github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, home-manager, caelestia-shell, caelestia-cli, zen-browser, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.hamish = { pkgs, ... }: {
            home.stateVersion = "25.05";
            home.packages = with pkgs; [
              # Essentials
              fish
              foot
              firefox
              neovim
              fuzzel
              wl-clipboard

              # LazyVim Requirements
              ripgrep
              tree-sitter
              fzf
              fd

              # Hyprland Config
              caelestia-shell.packages.${system}.default
              caelestia-cli.packages.${system}.default
              uwsm
              app2unit

              # Zen Browser
              zen-browser.packages.${system}.beta

              # QoL
              fastfetch
              starship
              eza
              lazygit
              btop
              darkman

              # Node.js
              nodejs_20
              yarn
              pnpm

              # Python
              python3
              python3Packages.virtualenv
              python3Packages.pip

              # Lua (mainly for Neovim)
              lua
              luajitPackages.luarocks
            ];

            systemd.user.services.uwsm = {
              Unit = {
                Description = "User Wayland Session Manager";
                After = [ "graphical-session-pre.target" ];
                PartOf = [ "graphical-session.target" ];
              };

              Service = {
                ExecStart = "${pkgs.uwsm}/bin/uwsm";
                Restart = "on-failure";
              };

              Install = { WantedBy = [ "graphical-session.target" ]; };
            };

            programs.fish.enable = true;

            programs.starship.enable = true;

            home.file.".config/darkman/config.yaml".text = ''
              usegeoclue: false
            '';

            gtk = {
                enable = true;
                theme = {
                  name = "Adwaita-dark";               # your default (pick what you like)
                  package = pkgs.gnome-themes-extra;
                };
                iconTheme = {
                  name = "Adwaita";
                  package = pkgs.gnome-themes-extra;
                };
              };

            # Hooks: executed by darkman when switching
            home.file.".local/share/darkman/dark-mode.d/10-gtk-dark" = {
              text = ''
                #!/usr/bin/env bash
                set -euo pipefail

                # Tell toolkits we prefer dark
                gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
                gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true

                # Nudge Hyprland to reload configs if needed
                command -v hyprctl >/dev/null && hyprctl reload || true
              '';
              executable = true;
            };

            home.file.".local/share/darkman/light-mode.d/10-gtk-light" = {
              text = ''
                #!/usr/bin/env bash
                set -euo pipefail

                gsettings set org.gnome.desktop.interface color-scheme 'default' 2>/dev/null || true
                gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' 2>/dev/null || true

                command -v hyprctl >/dev/null && hyprctl reload || true
              '';
              executable = true;
            };

            systemd.user.services.darkman = {
              Unit = {
                Description = "Darkman dark/light switcher";
                After = [ "graphical-session-pre.target" ];
                PartOf = [ "graphical-session.target" ];
              };

              Service = {
                Type = "dbus";
                BusName = "nl.whynothugo.darkman";
                ExecStart = "${pkgs.darkman}/bin/darkman run";
                Restart = "on-failure";
              };

              Install = { WantedBy = [ "graphical-session.target" ]; };
            };

            programs.git = {
              enable = true;
              settings.user = {
                name = "Hamish McLean";
                email = "hamish@condor.net.au";
              };
            };

            programs.ssh = {
                enable = true;
                enableDefaultConfig = false;
                addKeysToAgent = "yes";
                matchBlocks = {
                  "github.com" = {
                    forwardAgent = true;
                    identityFile = "~/.ssh/id_ed25519";
                  };
                };
              };
          };
        }
        ({ config, pkgs, ... }: {
          users.users.hamish.shell = pkgs.fish;
        })
      ];
    };
  };
}
