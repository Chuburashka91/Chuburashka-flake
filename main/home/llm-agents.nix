{ inputs, pkgs, ... }:
{
  # Добавляем бинарник pi в профиль пользователя
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
  ];
}
