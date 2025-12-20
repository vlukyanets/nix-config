{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.dev.rust;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.dev.rust = {
    enableStable = lib.mkEnableOption "Install Stable Rust";
    enableNightly = lib.mkEnableOption "Install Nightly Rust";
  };

  config = lib.mkIf (cfg.enableStable || cfg.enableNightly) {
    home.packages = [
      pkgs.gcc
      pkgs.pkg-config
    ]
    ++ lib.optional cfg.enableStable inputs.fenix.packages.${system}.stable.toolchain
    ++ lib.optional cfg.enableNightly inputs.fenix.packages.${system}.latest.toolchain;
  };
}
