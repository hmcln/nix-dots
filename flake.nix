{
  description = "Hamish NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };


  outputs = { self, nixpkgs, home-manager, ... }:
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

              # QoL
              fastfetch
              starship
              eza
              lazygit
              ripgrep
              tree-sitter
              fzf
              fd

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
            programs.fish.enable = true;
            programs.starship.enable = true;
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
                matchBlocks."*" = {
                  forwardAgent = true;
                  identityFile = "~/.ssh/id_ed25519";
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
