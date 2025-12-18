{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    mergerfs
  ];

  programs.fuse.userAllowOther = true;
}
