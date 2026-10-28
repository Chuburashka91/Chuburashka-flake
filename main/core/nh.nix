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
    flake = "/home/${username}/my-nixos-config";
  };
}
