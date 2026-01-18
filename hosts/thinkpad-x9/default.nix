{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Host-specific configuration for thinkpad-x9

  # Hostname
  networking.hostName = "thinkpad-x9";

  # You can add host-specific overrides here
  # For example:
  # - Monitor configuration
  # - Hardware-specific settings
  # - Performance tuning
  # - etc.
}
