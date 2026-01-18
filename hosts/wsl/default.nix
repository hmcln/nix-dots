{ config, lib, pkgs, ... }:

{
  networking.hostName = "wsl";

  wsl.enable = true;
  wsl.defaultUser = "hamish";

  # WSL does not use a bootloader or firmware settings.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  # WSL handles networking; NetworkManager is not required.
  networking.networkmanager.enable = lib.mkForce false;

  # Disable desktop/hardware services that are not available in WSL.
  services.xserver.enable = lib.mkForce false;
  services.displayManager.sddm.enable = lib.mkForce false;
  programs.hyprland.enable = lib.mkForce false;
  hardware.graphics.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;
  services.blueman.enable = lib.mkForce false;
  services.power-profiles-daemon.enable = lib.mkForce false;
  services.upower.enable = lib.mkForce false;
}
