{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    tree
    git
    curl
    wget
    coreutils
    neovim
    mc
  ];

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = true;
}

