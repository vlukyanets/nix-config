{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    nvtop
    nvidia-smi
    cudaPackages.cudatoolkit
    pciutils
    usbutils
    lm_sensors
  ];

  services.xserver.enable = false;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = false;
  };

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = false;
    powerManagement.enable = true;
    nvidiaPersistenced = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia-container-toolkit.enable = true;

  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];
  boot.blacklistedKernelModules = [ "nouveau" ];
}
