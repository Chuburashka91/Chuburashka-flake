{
  description = "My single NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";

    # Currently unused (kept so the lock file stays valid).
    maple-mono = {
      url = "github:subframe7536/maple-font?ref=v7.8";
      flake = false;
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-citizen.url = "github:LovingMelody/nix-citizen";

    zen-browser.url = "github:0xc000022070/zen-browser-flake/beta";

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs"; # важно для согласованности версий
    };
  };

  outputs =
    { self, nixpkgs, llm-agents, sops-nix, ... }@inputs:
    let
      username = "chu";
      system = "x86_64-linux";
      host = "chebupel";
      default-file-manager = "nemo";
      default-terminal = "kitty";
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./main
          sops-nix.nixosModules.sops
        ];
        specialArgs = {
          inherit default-file-manager default-terminal host username self inputs;
        };
      };
    };
}
