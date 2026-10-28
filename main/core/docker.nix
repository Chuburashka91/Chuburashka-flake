{ config, lib, pkgs, ... }:
{
virtualisation.docker.enable = true; 
virtualisation.docker.rootless = {
  enable = true;
  setSocketVariable = true; # Автоматически выставляет DOCKER_HOST
};
# Для повышения безопасности имеет смысл отключить системный демон

  environment.systemPackages = with pkgs; [
    compose2nix
    # ... остальные пакеты
  ];

}
