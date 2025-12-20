{ config, pkgs, inputs, ... }:
{
  imports =
    [
      ../../modules/home/dev/rust.nix
    ];

  home.username = "valentinl";
  home.homeDirectory = "/home/valentinl";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Valentin Lukyanets";
        email = "valikluks95@gmail.com";
      };

      init.defaultBranch = "master";
      pull.rebase = true;
      http.postBuffer = 524288000;
    };
  };
  programs.zsh.enable = true;

  dev.rust.enableStable = true;
}

