{ lib, config, pkgs, ... }:

{
  imports = [
    ./services
    ./cursor.nix
    ./hyprland
  ];
}
