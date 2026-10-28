{ pkgs, ... }:
{
  programs = {
    steam = {
      enable = true;

      gamescopeSession.enable = true;

      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
    gamescope = {
      enable = true;
      args = [
        "--rt"
        "--expose-wayland"
        "-W 3440"
        "-H 1440"
        "-f"
        "-r 144"
      ];
    };
  };

  hardware.steam-hardware.enable = true;
  #services.joycond.enable = true;
  #programs.joycond-cemuhook.enable = true;
  programs.gamemode.enable = true;
  environment.sessionVariables = {
    PROTON_ENABLE_NVAPI = "1";
    VKD3D_CONFIG = "dxr";
  };
}
