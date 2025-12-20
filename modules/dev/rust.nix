# modules/nixos/rust.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.dev.rust;
in
{
  options.dev.rust = {
    enable = lib.mkEnableOption "Rust toolchain";

    toolchain = lib.mkOption {
      type = lib.types.enum [ "nixpkgs" "stable" "nightly" ];
      default = "stable";
      description = ''
        Which Rust toolchain to install:
        - nixpkgs: pkgs.rustc + pkgs.cargo from nixpkgs
        - stable: rust-bin stable (official builds)
        - nightly: rust-bin nightly (official builds)
      '';
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ pkgs.rust-analyzer pkgs.clippy pkgs.rustfmt ];
      description = "Extra Rust-related packages to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      let
        toolchainPkg =
          if cfg.toolchain == "nixpkgs" then [ pkgs.rustc pkgs.cargo ]
          else if cfg.toolchain == "nightly" then [ pkgs.rust-bin.nightly.latest.default ]
          else [ pkgs.rust-bin.stable.latest.default ];
      in
      toolchainPkg ++ cfg.extraPackages;
  };
}

