{ config, lib, pkgs, ... }:

let
  cfg = config.roles.powlK8s;
in
{
  options.roles.powlK8s = {
    enable = lib.mkEnableOption "POWL on Kubernetes";
    repoDir = lib.mkOption { type = lib.types.str; default = "/opt/powl"; };
    masterAddress = lib.mkOption { type = lib.types.str; description = "Kubernets master address (IP or hostname). Set in host config"; };
    openFirewall = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ kubectl ];
    services.kubernetes.roles = [ "master" "node" ];
    services.kubernetes.flannel.enable = true;
    services.kubernetes.masterAddress = cfg.masterAddress;
    # (Optional) some people also enable these explicitly; roles usually covers it:
    # services.kubernetes.apiserver.enable = true;
    # services.kubernetes.controllerManager.enable = true;
    # services.kubernetes.scheduler.enable = true;
    # services.kubernetes.kubelet.enable = true;

    systemd.tmpfiles.rules = [
      "d ${cfg.repoDir} 0755 root root - -"
      "d ${cfg.repoDir}/models 0755 root root - -"
      "d ${cfg.repoDir}/models/ollama 0755 root root - -"
      "d ${cfg.repoDir}/models/whisper 0755 root root - -"
      "d ${cfg.repoDir}/models/piper 0755 root root - -"
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 30080 ];
  };
}

