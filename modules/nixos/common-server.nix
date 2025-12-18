{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    screen
    htop
    iotop
    iftop
    lsof
    ncdu
    strace
    rsync
    rclone
    smartmontools
    hdparm
    fio
    duf
  ];
}
