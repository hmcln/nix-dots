{ lib, config, pkgs, ... }:

with lib;

{
  options = {
    persistence = {
      directories = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of directories to persist";
      };
    };

    darkman = {
      switchScripts = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "Scripts to run when switching themes with darkman";
      };
    };
  };

  config = {
    # Persistence handling would go here if you have impermanence or similar
  };
}
