{ config, pkgs, lib, ... }:

{
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-personalization
    pam_u2f
  ];

  security.pam.u2f = {
    enable = true;
    settings.cue = true;
  };
}
