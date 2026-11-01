{ username, ... }:
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      # Keep the last 10 generations and clean the rest once a month.
      dates = "monthly";
      extraArgs = "--keep 10";
    };
    # Workspace root is not the repo: the flake lives in repo/ after the
    # 2026-11-01 restructure (`main/core/pi.nix` still mounts ../.pi).
    flake = "/home/${username}/agent-workspace/workspace/rice/repo";
  };
}
