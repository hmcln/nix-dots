{ lib, config, pkgs, ... }:

{
  imports = [
    ./programs
    ./desktop
    ./persistence.nix
  ];
}
