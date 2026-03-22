{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/nixos/common.nix
      ../../modules/nixos/common-client.nix
      ../../modules/nixos/niri.nix
      ../../modules/nixos/uki-boot.nix
      ../../modules/nixos/yubikey-client.nix
    ];

  networking.hostName = "hyper-lin";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Kyiv";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.valentinl = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMx7rCshYpRaCXKWXukP20XqAhcQI17cwMfX0cPdVseL valentinl@nova-win-work"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFv4E2OIw3oPMCxyC2oDWlWqn0lrcq0gsom7vwsq8p2r valentinl@hyper-win"
    ];
  };

  programs.zsh.enable = true;

  # PipeWire audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    };
  };

  # Lid switch: suspend on battery, ignore on AC
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "poweroff";
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    lvm2
    cryptsetup
    ripgrep
    htop
    pciutils
    firefox
    zsh
  ];

  services.openssh.settings = {
    PasswordAuthentication = false;
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

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.11";
}
