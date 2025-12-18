{ config, pkgs, ... }:
{
  home.username = "valentinl";
  home.homeDirectory = "/home/valentinl";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Valentin Lukyanets";
        email = "valikluks95@gmail.com";
      };

      init.defaultBranch = "master";
      pull.rebase = true;
    };
  };
  programs.zsh.enable = true;
}

