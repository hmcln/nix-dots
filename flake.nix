{
  description = "Hamish NixOS (flake bootstrap)";

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
          home-manager.users.hamish = { pkgs, ... }: {
            home.stateVersion = "25.05";
            home.packages = with pkgs; [
              fastfetch eza fuzzel foot wl-clipboard neovim git starship fish
            ];
            programs.fish.enable = true;
            programs.starship.enable = true;
            programs.git = {
              enable = true;
              userName = "Hamish McLean";
              userEmail = "you@example.com";
            };
            programs.ssh.enable = true;
          };
        }
        { users.users.hamish.shell = nixpkgs.legacyPackages.${system}.fish; }
      ];
    };
  };
}
