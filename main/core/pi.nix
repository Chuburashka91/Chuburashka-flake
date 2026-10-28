{ config, pkgs, username, lib, ... }:

let
  # Rootless Podman container for the pi agent.
  # Docker stays the global oci-containers backend (b4/stoat still use it).
  #
  # Why Podman here: --userns=keep-id maps the host user (chu:users) to the
  # same UID/GID inside the container, so files written by the agent are
  # owned by the host user (chu:users) on the host.
  piContainer = "pi-agent";
  piHome = config.users.users.${username}.home;
  piConfig = "${piHome}/agent-workspace/workspace/rice/.pi";
  piUid = "1000";
  piGid = "100";
  piEnv = config.sops.templates."deepseek.env".path;

  piPreStart = pkgs.writeShellScript "pi-agent-pre-start" ''
    set -euo pipefail
    ${pkgs.podman}/bin/podman rm -f ${piContainer} >/dev/null 2>&1 || true
    rm -f /run/user/${piUid}/${piContainer}/ctr-id
  '';

  piStart = pkgs.writeShellScript "pi-agent-start" ''
    set -euo pipefail
    exec ${pkgs.podman}/bin/podman run \
      --name=${piContainer} \
      --cidfile=/run/user/${piUid}/${piContainer}/ctr-id \
      --cgroups=enabled \
      --sdnotify=conmon \
      -d --replace \
      --network=host \
      --userns=keep-id \
      -u ${piUid}:${piGid} \
      -e HOME=/home/node \
      --workdir /workspace \
      --env-file ${piEnv} \
      -v ${piHome}/agent-workspace:/workspace \
      -v ${piConfig}:/home/node/.pi \
      --entrypoint /bin/sh \
      ocramz/pi-container -c 'sleep infinity'
  '';

  piStop = pkgs.writeShellScript "pi-agent-stop" ''
    ${pkgs.podman}/bin/podman stop --ignore --cidfile=/run/user/${piUid}/${piContainer}/ctr-id || true
    ${pkgs.podman}/bin/podman rm -f --ignore --cidfile=/run/user/${piUid}/${piContainer}/ctr-id || true
  '';
in
{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";
  virtualisation.podman.enable = true;
  virtualisation.containers.registries.search = [ "docker.io" ];
  # Rootless podman needs a lingering user session so the service starts at boot.
  users.users.${username}.linger = true;
  users.manageLingering = true;
   
  systemd.tmpfiles.rules = [
  "d /run/user/${piUid} 0700 ${username} ${config.users.users.${username}.group} -"
];

    systemd.user.services.${piContainer} = {
    description = "pi agent container (rootless Podman, keep-id)";
    wantedBy = [ "default.target" ]; # Цель пользовательской сессии
    wants = [ "sops-install-secrets.service" ];
    after = [ "sops-install-secrets.service" ];

    unitConfig.RequiresMountsFor = "/run/user/${piUid}/containers";

    environment = {
      HOME = piHome;
      PODMAN_SYSTEMD_UNIT = "${piContainer}.service";
      XDG_RUNTIME_DIR = "/run/user/${piUid}";
    };

    path = [ pkgs.podman pkgs.coreutils "/run/wrappers" ];

    serviceConfig = {
      Type = "notify";
      NotifyAccess = "all";
      Delegate = true;
      #User = username;
      RuntimeDirectory = piContainer;
      Restart = "on-failure";
      TimeoutStartSec = 0;
      TimeoutStopSec = 120;
      ExecStartPre = "${piPreStart}";
      ExecStart = "${piStart}";
      ExecStop = "${piStop}";
    };
  };
}
