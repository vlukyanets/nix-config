{ config, lib, pkgs, ... }:

let
  cfg = config.services.lmstudio-server;
in
{
  options.services.lmstudio-server = {
    enable = lib.mkEnableOption "LM Studio AI model server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 1234;
      description = "Port to expose the LM Studio API on";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/lmstudio";
      description = "Directory for LM Studio models and data";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the firewall for the LM Studio API port";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.lmstudio = {
      isSystemUser = true;
      group = "lmstudio";
      home = cfg.dataDir;
      createHome = true;
      description = "LM Studio service user";
    };

    users.groups.lmstudio = { };

    environment.systemPackages = [ pkgs.lmstudio ];

    systemd.services.lmstudio = {
      description = "LM Studio AI model server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        HOME = cfg.dataDir;
      };

      serviceConfig = {
        Type = "simple";
        User = "lmstudio";
        Group = "lmstudio";
        ExecStart = "${pkgs.lmstudio}/bin/lms server start --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "5s";
        StateDirectory = "lmstudio";
        StateDirectoryMode = "0750";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
