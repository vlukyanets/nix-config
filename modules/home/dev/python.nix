{ config, lib, pkgs, ... }:

let
  cfg = config.dev.python;
in {
  options.dev.python = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install Python 3.";
    };

    libraries = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of python packages to install (from python3Packages).";
    };

    enableDevTools = lib.mkEnableOption "Common Python dev tools (black, isort, etc)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.python3.withPackages (ps: 
        (builtins.map (name: ps.${name}) cfg.libraries)
        ++ lib.optionals cfg.enableDevTools [
          ps.black
          ps.isort
          ps.pip
          ps.pytest
        ]
      ))
    ];
  };
}
