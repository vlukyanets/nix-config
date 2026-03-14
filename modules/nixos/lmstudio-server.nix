{ config, lib, pkgs, ... }:

let
  cfg = config.services.lmstudio;

  startScript = pkgs.writeShellScript "lmstudio-start" ''
    # Dynamic CPU allocation: total cores minus reserved for host
    TOTAL_CPUS=$(${pkgs.coreutils}/bin/nproc)
    CONTAINER_CPUS=$((TOTAL_CPUS - ${toString cfg.reservedCPUs}))
    if [ "$CONTAINER_CPUS" -lt 1 ]; then
      CONTAINER_CPUS=1
    fi

    # Dynamic memory allocation: total RAM minus reserved for host
    TOTAL_MEM_KB=$(${pkgs.gawk}/bin/awk '/MemTotal/ {print $2}' /proc/meminfo)
    RESERVED_MEM_KB=$((${toString cfg.reservedMemoryMB} * 1024))
    CONTAINER_MEM_KB=$((TOTAL_MEM_KB - RESERVED_MEM_KB))
    if [ "$CONTAINER_MEM_KB" -lt 1048576 ]; then
      CONTAINER_MEM_KB=1048576
    fi
    CONTAINER_MEM_MB=$((CONTAINER_MEM_KB / 1024))

    echo "LM Studio: allocating $CONTAINER_CPUS/$TOTAL_CPUS CPUs and ''${CONTAINER_MEM_MB}MB RAM (reserved: ${toString cfg.reservedCPUs} CPUs, ${toString cfg.reservedMemoryMB}MB RAM for host)"

    exec ${pkgs.podman}/bin/podman run \
      --name lmstudio \
      --rm \
      --device nvidia.com/gpu=all \
      --cpus "$CONTAINER_CPUS" \
      --memory "''${CONTAINER_MEM_MB}m" \
      -p ${toString cfg.port}:1234 \
      -v ${cfg.dataDir}:/root/.lmstudio \
      ${cfg.image}
  '';

  linkSetupScript = pkgs.writeShellScript "lmstudio-link-setup" ''
    # Wait for the LM Studio daemon inside the container to become ready
    echo "LM Link: waiting for LM Studio daemon..."
    for i in $(${pkgs.coreutils}/bin/seq 1 60); do
      if ${pkgs.podman}/bin/podman exec lmstudio lms status >/dev/null 2>&1; then
        echo "LM Link: daemon is ready"
        break
      fi
      ${pkgs.coreutils}/bin/sleep 2
    done

    # Authenticate with pre-authenticated keys (headless)
    KEY_ID=$(${pkgs.coreutils}/bin/cat ${cfg.lmLink.keyIdFile})
    PUBLIC_KEY=$(${pkgs.coreutils}/bin/cat ${cfg.lmLink.publicKeyFile})
    PRIVATE_KEY=$(${pkgs.coreutils}/bin/cat ${cfg.lmLink.privateKeyFile})

    echo "LM Link: logging in..."
    ${pkgs.podman}/bin/podman exec lmstudio lms login \
      --with-pre-authenticated-keys \
      --key-id "$KEY_ID" \
      --public-key "$PUBLIC_KEY" \
      --private-key "$PRIVATE_KEY"

    echo "LM Link: enabling link..."
    ${pkgs.podman}/bin/podman exec lmstudio lms link enable
    echo "LM Link: active"
  '';
in
{
  options.services.lmstudio = {
    enable = lib.mkEnableOption "LM Studio server in a container";

    image = lib.mkOption {
      type = lib.types.str;
      default = "noneabove1182/lmstudio-cuda:latest";
      description = "OCI image for LM Studio with CUDA/GPU support";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1234;
      description = "Host port to expose the LM Studio API on";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/lmstudio";
      description = "Host directory for persistent LM Studio models and data";
    };

    reservedCPUs = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Number of CPU cores to reserve for the host OS";
    };

    reservedMemoryMB = lib.mkOption {
      type = lib.types.int;
      default = 2048;
      description = "Memory in MB to reserve for the host OS";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the firewall for the LM Studio API port";
    };

    lmLink = {
      enable = lib.mkEnableOption "LM Link for remote model access via Tailscale mesh";

      keyIdFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to file containing the LM Studio Hub key ID (generate at lmstudio.ai)";
      };

      publicKeyFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to file containing the LM Studio Hub public key";
      };

      privateKeyFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to file containing the LM Studio Hub private key";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    # Main container service
    systemd.services.lmstudio = {
      description = "LM Studio Server (container)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 10;
        ExecStartPre = [
          "${pkgs.podman}/bin/podman pull ${cfg.image}"
          "-${pkgs.podman}/bin/podman rm -f lmstudio"
        ];
        ExecStart = "${startScript}";
        ExecStop = "${pkgs.podman}/bin/podman stop lmstudio";
        TimeoutStartSec = 300;
        TimeoutStopSec = 30;
      };
    };

    # LM Link setup as a separate service so a link failure doesn't bring down the container
    systemd.services.lmstudio-link = lib.mkIf cfg.lmLink.enable {
      description = "LM Studio Link Setup";
      after = [ "lmstudio.service" ];
      requires = [ "lmstudio.service" ];
      partOf = [ "lmstudio.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${linkSetupScript}";
        Restart = "on-failure";
        RestartSec = 15;
      };
    };
  };
}
