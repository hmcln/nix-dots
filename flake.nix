{
  description = "Hamish NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

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
      nixos-wsl,
      caelestia-shell,
      caelestia-cli,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "1password-gui"
            "1password"
            "1password-cli"
            "slack"
            "todoist-electron"
            "spotify"
          ];
      };

      # Extra arguments passed to all Home Manager modules
      extraSpecialArgs = {
        inherit caelestia-shell caelestia-cli system;
      };
    in
    {
      # Standalone home-manager configuration (can be built without sudo)
      homeConfigurations.hamish = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./hosts/hamish/home.nix
          {
            home.username = "hamish";
            home.homeDirectory = "/home/hamish";
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
            home-manager.extraSpecialArgs = extraSpecialArgs;
            home-manager.users.hamish = ./hosts/hamish/home.nix;
          }
          (
            { config, pkgs, ... }:
            {
              users.users.hamish.shell = pkgs.fish;
            }
          )
        ];
      };

      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./hosts/wsl
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = extraSpecialArgs;
            home-manager.users.hamish =
              { pkgs, ... }:
              {
                imports = [ ./modules ];

                home.stateVersion = "25.05";

                # Enable CLI-focused modules on WSL
                modules.programs.neovim.enable = true;
                modules.programs.btop.enable = true;
                modules.programs.fish.enable = true;
                modules.programs.starship.enable = true;
                modules.programs.lazygit.enable = true;

                # Disable desktop-specific modules on WSL
                modules.desktop.hyprland.enable = false;
                modules.programs.caelestia.enable = false;
                modules.desktop.style.cursor.enable = false;
              };
          }
        ];
      };
    };
}
