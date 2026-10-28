{ config, pkgs, inputs, ... }:
{
sops.defaultSopsFile = "${inputs.self}/secrets/common.yaml";
sops.age.keyFile = "/home/chu/.config/sops/age/keys.txt";
sops.secrets = {
  "deepseek_key".key = "deepseek_key";
  "git_hub_key".key = "git_guid";
};

sops.templates."nix-access-tokens.conf".content = ''
    access-tokens = github.com=${config.sops.placeholder."git_hub_key"}
  '';
  sops.templates."deepseek.env".content = ''
  DEEPSEEK_API_KEY=${config.sops.placeholder."deepseek_key"}
'';
  sops.templates."deepseek.env".mode = "0444";
  nix.extraOptions = ''
    !include ${config.sops.templates."nix-access-tokens.conf".path}
  '';
}
