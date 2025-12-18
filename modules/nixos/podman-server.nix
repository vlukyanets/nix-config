{ config, pkgs, lib, ... }:

{
  virtualisation.podman = {
    enable = true;

    dockerCompat = true;
    dockerSocket.enable = true;

    extraPackages = with pkgs; [
      slirp4netns
      fuse-overlayfs
    ];

    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  virtualisation.containers.containersConf.settings = {
    containers = {
      log_driver = "journald";
    };
  };

  environment.systemPackages = with pkgs; [
    podman
    podman-compose
    buildah
    skopeo
  ];

  #### Firewall note ####
  # Podman uses netavark/aardvark-dns by default; typically no special firewall config is needed.
  # If you publish ports (-p), ensure networking.firewall.allowedTCPPorts includes them on that host.
}
