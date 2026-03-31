{ config, lib, pkgs, ... }:

let
  cfg = config.services.ollama-server;
in
{
  imports = [ ./podman-server.nix ];

  options.services.ollama-server = {
    enable = lib.mkEnableOption "Ollama AI model server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      description = "Port to expose the Ollama API on";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/ollama";
      description = "Directory for Ollama models and data";
    };

    acceleration = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "cuda" "rocm" ]);
      default = "cuda";
      description = "Hardware acceleration (cuda, rocm, or null for CPU only)";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the firewall for the Ollama API port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      port = cfg.port;
      home = cfg.dataDir;
      acceleration = cfg.acceleration;
    };

    # Ollama depends on Podman being active
    systemd.services.ollama = {
      after = [ "podman.service" ];
      requires = [ "podman.service" ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
