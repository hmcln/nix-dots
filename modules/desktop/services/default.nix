{ lib, config, pkgs, ... }:

with lib;

{
  options.modules.desktop.services = {
    darkman = {
      enable = mkEnableOption "Darkman dark/light theme switcher";
    };
  };

  config = mkIf config.modules.desktop.services.darkman.enable {
    # Darkman service configuration will be handled in the neovim module
  };
}
