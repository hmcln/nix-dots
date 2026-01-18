{
  description = "Hamish NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    caelestia-shell = {
      url = "github:hmcln/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-cli = {
      url = "github:hmcln/cli";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.caelestia-shell.follows = "caelestia-shell";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      caelestia-shell,
      caelestia-cli,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
          "1password-gui"
          "1password"
          "1password-cli"
          "slack"
          "todoist-electron"
          "spotify"
        ];
      };
    in
    {
      # Standalone home-manager configuration (can be built without sudo)
      homeConfigurations.hamish = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./modules
          {
            home.username = "hamish";
            home.homeDirectory = "/home/hamish";
            home.stateVersion = "25.05";

            # Enable modules
            modules.programs.neovim.enable = true;
            modules.programs.btop.enable = true;
            modules.programs.foot.enable = true;
            modules.programs.lazygit.enable = true;
            modules.programs.fish.enable = true;
            modules.programs.starship.enable = true;
            modules.programs.caelestia.enable = true;
            modules.desktop.style.cursor.enable = true;
            modules.desktop.hyprland.enable = true;

            # Hyprland configuration
            modules.desktop.hyprland = {
              monitors = [
                "HDMI-A-1,3840x2160,-2560x-540,1.5"
                "DP-1,2560x1440,-2560x0,1"
              ];

              workspaces = [
                { id = 1; monitor = 0; persistent = true; }
                { id = 2; monitor = 0; persistent = true; }
                { id = 3; monitor = 0; persistent = true; }
                { id = 4; monitor = 0; persistent = true; }
                { id = 5; monitor = 0; persistent = true; }
                { id = 6; monitor = 1; persistent = true; }
                { id = 7; monitor = 1; persistent = true; }
                { id = 8; monitor = 1; persistent = true; }
                { id = 9; monitor = 1; persistent = true; }
                { id = 10; monitor = 1; persistent = true; }
              ];
            };

            # Caelestia configuration
            modules.programs.caelestia = {
              wallpaperBackend = "swww";
              swww = {
                transitionType = "fade";
                transitionDuration = 2;
              };
              theme = {
                enableTerm = true;
                enableHypr = true;
                enableDiscord = true;
                enableFuzzel = true;
                enableBtop = true;
              };
            };

            home.packages = with pkgs; [
              # Home Manager CLI
              home-manager

              # Essentials
              fish
              firefox
              fuzzel
              wl-clipboard
              pavucontrol
              thunderbird

              slack
              todoist-electron
              spotify

              # LazyVim Requirements
              ripgrep
              tree-sitter
              fzf
              fd

              # File Explorer
              thunar

              # Web Browser
              (chromium.override {
                commandLineArgs = [
                  "--disable-features=WaylandWpColorManagerV1"
                ];
              })

              # Database Viewer
              dbeaver-bin

              # Hyprland Config
              caelestia-shell.packages.${system}.default
              caelestia-cli.packages.${system}.default
              uwsm
              app2unit

              # QoL
              fastfetch
              starship
              eza
              darkman

              # Node.js
              nodejs_20
              yarn
              pnpm

              # TS DevEx
              nodePackages.typescript
              nodePackages.vscode-langservers-extracted
              nodePackages.typescript-language-server
              nodePackages.eslint
              nodePackages.prettier

              # Python
              python3
              python3Packages.virtualenv
              python3Packages.pip
              uv

              # Lua (mainly for Neovim)
              lua
              luajitPackages.luarocks

              # LSP Servers (for Neovim)
              lua-language-server
              nil
              pyright
              ruff

              # Formatters (for Neovim)
              black # Python formatter
              stylua # Lua formatter
              shfmt # Shell script formatter
            ];

            home.file.".config/darkman/config.yaml".text = ''
              usegeoclue: false
            '';

            gtk = {
              enable = true;
              theme = {
                name = "Adwaita-dark";
                package = pkgs.gnome-themes-extra;
              };
              iconTheme = {
                name = "Adwaita";
                package = pkgs.adwaita-icon-theme;
              };
              gtk3.extraConfig = {
                gtk-application-prefer-dark-theme = true;
              };
              gtk4.extraConfig = {
                gtk-application-prefer-dark-theme = true;
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

              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
            };

            programs.git = {
              enable = true;
              settings.user = {
                name = "Hamish McLean";
                email = "hamish.mclean@biarri.com";
              };
            };

            programs.ssh = {
              enable = true;
              enableDefaultConfig = false;
              matchBlocks = {
                "*" = {
                  addKeysToAgent = "yes";
                  forwardAgent = true;
                };
                # Work account (bhmcln)
                "github.com" = {
                  identityFile = "~/.ssh/id_ed25519";
                  identitiesOnly = true;
                };
                # Personal account (hmcln)
                "condor" = {
                  hostname = "github.com";
                  identityFile = "~/.ssh/id_ed25519_condor";
                  identitiesOnly = true;
                };
                "gitlab.com" = {
                  identityFile = "~/.ssh/id_ed25519";
                };
              };
            };

            # SSH agent service for persistent authentication
            services.ssh-agent = {
              enable = true;
            };
          }
        ];
      };

      nixosConfigurations.thinkpad-x9 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./hosts/thinkpad-x9
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.hamish =
              { pkgs, ... }:
              {
                imports = [ ./modules ];

                home.stateVersion = "25.05";

                # Enable modules
                modules.programs.neovim.enable = true;
                modules.programs.btop.enable = true;
                modules.programs.foot.enable = true;
                modules.programs.lazygit.enable = true;
                modules.programs.fish.enable = true;
                modules.programs.starship.enable = true;
                modules.programs.caelestia.enable = true;
                modules.desktop.style.cursor.enable = true;
                modules.desktop.hyprland.enable = true;

                # Hyprland configuration
                modules.desktop.hyprland = {
                  monitors = [
                    "HDMI-A-1,3840x2160,-2560x-540,1.5"
                    "DP-1,2560x1440,-2560x0,1"
                  ];

                  workspaces = [
                    { id = 1; monitor = 0; persistent = true; }
                    { id = 2; monitor = 0; persistent = true; }
                    { id = 3; monitor = 0; persistent = true; }
                    { id = 4; monitor = 0; persistent = true; }
                    { id = 5; monitor = 0; persistent = true; }
                    { id = 6; monitor = 1; persistent = true; }
                    { id = 7; monitor = 1; persistent = true; }
                    { id = 8; monitor = 1; persistent = true; }
                    { id = 9; monitor = 1; persistent = true; }
                    { id = 10; monitor = 1; persistent = true; }
                  ];
                };

                # Caelestia configuration
                modules.programs.caelestia = {
                  wallpaperBackend = "swww";
                  swww = {
                    transitionType = "fade";
                    transitionDuration = 2;
                  };
                  theme = {
                    enableTerm = true;
                    enableHypr = true;
                    enableDiscord = true;
                    enableFuzzel = true;
                    enableBtop = true;
                  };
                };

                home.packages = with pkgs; [
                  # Home Manager CLI (for sudo-free rebuilds)
                  home-manager

                  # Essentials
                  fish
                  firefox
                  fuzzel
                  wl-clipboard
                  pavucontrol
                  thunderbird

                  slack
                  todoist-electron
                  spotify

                  # LazyVim Requirements
                  ripgrep
                  tree-sitter
                  fzf
                  fd

                  # File Explorer
                  thunar

                  # Web Browser
                  (chromium.override {
                    commandLineArgs = [
                      "--disable-features=WaylandWpColorManagerV1"
                    ];
                  })

                  # Database Viewer
                  dbeaver-bin

                  # Hyprland Config
                  caelestia-shell.packages.${system}.default
                  caelestia-cli.packages.${system}.default
                  uwsm
                  app2unit

                  # QoL
                  fastfetch
                  starship
                  eza
                  darkman

                  # Node.js
                  nodejs_20
                  yarn
                  pnpm

                  # TS DevEx
                  nodePackages.typescript
                  nodePackages.vscode-langservers-extracted
                  nodePackages.typescript-language-server
                  nodePackages.eslint
                  nodePackages.prettier

                  # Python
                  python3
                  python3Packages.virtualenv
                  python3Packages.pip
                  uv

                  # Lua (mainly for Neovim)
                  lua
                  luajitPackages.luarocks

                  # LSP Servers (for Neovim)
                  lua-language-server
                  nil
                  pyright
                  ruff

                  # Formatters (for Neovim)
                  black # Python formatter
                  stylua # Lua formatter
                  shfmt # Shell script formatter
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

                  Install = {
                    WantedBy = [ "graphical-session.target" ];
                  };
                };

                home.file.".config/darkman/config.yaml".text = ''
                  usegeoclue: false
                '';

                gtk = {
                  enable = true;
                  theme = {
                    name = "Adwaita-dark"; # your default (pick what you like)
                    package = pkgs.gnome-themes-extra;
                  };
                  iconTheme = {
                    name = "Adwaita";
                    package = pkgs.adwaita-icon-theme;
                  };
                  gtk3.extraConfig = {
                    gtk-application-prefer-dark-theme = true;
                  };
                  gtk4.extraConfig = {
                    gtk-application-prefer-dark-theme = true;
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

                  Install = {
                    WantedBy = [ "graphical-session.target" ];
                  };
                };

                programs.git = {
                  enable = true;
                  settings.user = {
                    name = "Hamish McLean";
                    email = "hamish.mclean@biarri.com";
                  };
                };

                programs.ssh = {
                  enable = true;
                  enableDefaultConfig = false;
                  matchBlocks = {
                    "*" = {
                      addKeysToAgent = "yes";
                      forwardAgent = true;
                    };
                    # Work account (bhmcln)
                    "github.com" = {
                      identityFile = "~/.ssh/id_ed25519";
                      identitiesOnly = true;
                    };
                    # Personal account (hmcln)
                    "condor" = {
                      hostname = "github.com";
                      identityFile = "~/.ssh/id_ed25519_condor";
                      identitiesOnly = true;
                    };
                    "gitlab.com" = {
                      identityFile = "~/.ssh/id_ed25519";
                    };
                  };
                };

                # SSH agent service for persistent authentication
                services.ssh-agent = {
                  enable = true;
                };
              };
          }
          (
            { config, pkgs, ... }:
            {
              users.users.hamish.shell = pkgs.fish;
            }
          )
        ];
      };
    };
}
