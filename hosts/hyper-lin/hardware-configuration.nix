{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Kernel modules
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "dm-mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # LUKS2 encrypted partition → LVM
  boot.initrd.luks.devices."cryptlvm" = {
    # TODO: replace with actual UUID of your LUKS partition
    # Use: blkid /dev/sdX2 (or nvme0n1p2) to find it
    device = "/dev/disk/by-uuid/CHANGE-ME-LUKS-UUID";
    preLVM = true;
    allowDiscards = true;  # SSD TRIM support through LUKS
  };

  # BTRFS subvolumes on LVM logical volume
  fileSystems."/" =
    { device = "/dev/vg0/root";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  fileSystems."/home" =
    { device = "/dev/vg0/root";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  fileSystems."/nix" =
    { device = "/dev/vg0/root";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/vg0/root";
      fsType = "btrfs";
      options = [ "subvol=@log" "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  fileSystems."/.snapshots" =
    { device = "/dev/vg0/root";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  # EFI System Partition
  fileSystems."/boot" =
    { # TODO: replace with actual UUID of your EFI partition
      # Use: blkid /dev/sdX1 (or nvme0n1p1) to find it
      device = "/dev/disk/by-uuid/CHANGE-ME-EFI-UUID";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  # Swap on dedicated LVM logical volume
  swapDevices = [
    { device = "/dev/vg0/swap"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
