{ config, pkgs, lib, ... }:

{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.bootspec.enable = true;

  boot.uki = {
    settings = {
      PCRSignature = {
        # Sign PCR policy for banks 7 (Secure Boot) and 11 (UKI)
        Banks = "sha256";
      };
    };
  };

  boot.loader.external = {
    enable = true;
    installHook = let
      ukify = "${pkgs.systemd}/lib/systemd/ukify";
      sbsign = "${pkgs.sbsigntool}/bin/sbsign";
      bootctl = "${pkgs.systemd}/bin/bootctl";
    in "${pkgs.writeShellScript "install-uki" ''
      set -euo pipefail

      ESP="/boot"
      KEYS_DIR="/etc/secureboot/keys"
      ENTRY_DIR="$ESP/EFI/Linux"

      mkdir -p "$ENTRY_DIR"

      # Process each generation from bootspec
      for entry in /nix/var/nix/profiles/system-*-link; do
        [ -e "$entry" ] || continue

        GENERATION=$(basename "$entry" | sed 's/system-\([0-9]*\)-link/\1/')
        BOOTSPEC="$entry/boot.json"
        [ -f "$BOOTSPEC" ] || continue

        KERNEL=$(${pkgs.jq}/bin/jq -r '.["org.nixos.bootspec.v1"].kernel' "$BOOTSPEC")
        INITRD=$(${pkgs.jq}/bin/jq -r '.["org.nixos.bootspec.v1"].initrd' "$BOOTSPEC")
        INIT=$(${pkgs.jq}/bin/jq -r '.["org.nixos.bootspec.v1"].init' "$BOOTSPEC")
        PARAMS=$(${pkgs.jq}/bin/jq -r '.["org.nixos.bootspec.v1"].kernelParams | join(" ")' "$BOOTSPEC")

        UKI_FILE="$ENTRY_DIR/nixos-generation-$GENERATION.efi"

        if [ -f "$UKI_FILE" ]; then
          continue
        fi

        # Build UKI with ukify
        ${ukify} build \
          --linux="$KERNEL" \
          --initrd="$INITRD" \
          --cmdline="init=$INIT $PARAMS" \
          --os-release="@/etc/os-release" \
          --output="$UKI_FILE.unsigned"

        # Sign the UKI if keys are available
        if [ -f "$KEYS_DIR/db/db.key" ] && [ -f "$KEYS_DIR/db/db.pem" ]; then
          ${sbsign} \
            --key "$KEYS_DIR/db/db.key" \
            --cert "$KEYS_DIR/db/db.pem" \
            --output "$UKI_FILE" \
            "$UKI_FILE.unsigned"
          rm -f "$UKI_FILE.unsigned"
        else
          mv "$UKI_FILE.unsigned" "$UKI_FILE"
          echo "WARNING: Secure Boot keys not found at $KEYS_DIR, UKI is unsigned"
        fi
      done

      # Install systemd-boot as the EFI boot manager
      ${bootctl} install --esp-path="$ESP" 2>/dev/null || ${bootctl} update --esp-path="$ESP"
    ''}";
  };

  boot.initrd.systemd.enable = true;

  # TPM2 support for LUKS auto-unlock (user must enroll via systemd-cryptenroll)
  boot.initrd.systemd.tpm2.enable = true;

  environment.systemPackages = with pkgs; [
    sbsigntool
    efitools
    systemd  # provides ukify and bootctl
    jq
  ];
}
