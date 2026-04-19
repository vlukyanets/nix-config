{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/nixos/common.nix
      ../../modules/nixos/common-server.nix
      ../../modules/nixos/file-server.nix
      ../../modules/nixos/podman-linger-by-group.nix
      ../../modules/nixos/podman-server.nix
      ../../modules/nixos/nvidia-server.nix
      ../../modules/nixos/ollama-server.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "echo-server";

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  time.timeZone = "Europe/Kyiv";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.valentinl = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "containers" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL4ge7qLArJtKK76wOgm01k8nxiyvMq5Y4VaGRbosJgt valentinl@nova-win"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErw2qRdkMyG3H9blSB5V2VBK0RHLdbgmkLUjYy2GP99 valentinl@hyper-lin"
    ];
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    pciutils
    ripgrep
    htop
    btrfs-progs
    zsh
  ];

  services.logind.settings.Login = {
    IdleAction = "ignore";
    HandlePowerKey = "ignore";
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    KillUserProcesses = false;
  };

  services.openssh.settings = {
    PasswordAuthentication = true;
    PermitRootLogin = "no";
  };

  services.timesyncd.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  services.ollama-server.enable = true;

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.11";
}
