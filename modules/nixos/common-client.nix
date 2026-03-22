{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
    lsof
    ncdu
    duf
    rsync
    usbutils
    pciutils
    wl-clipboard
  ];

  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "Liberation Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
