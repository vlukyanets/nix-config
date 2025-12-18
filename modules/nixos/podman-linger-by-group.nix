{ config, lib, pkgs, ... }:

let
  lingerGroup = "containers";
in
{
  users.groups.${lingerGroup} = {};

  system.activationScripts.enableLingerForGroup.text = ''
    group="${lingerGroup}"

    for user in $(getent group "$group" | cut -d: -f4 | tr ',' ' '); do
      if [ -n "$user" ]; then
        ${pkgs.systemd}/bin/loginctl enable-linger "$user" || true
      fi
    done
  '';
}

