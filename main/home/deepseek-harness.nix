{ pkgs, ... }:
let
  # Nixpkgs-built Node breaks node-addon-require-builtin because its getter
  # machine code has a leaf frame pointer.  A manually unpacked official
  # nodejs.org binary works on NixOS, but autoPatchelfHook made that binary
  # segfault in ld.so.  Install it verbatim, without patchELF.
  nodejs = pkgs.stdenv.mkDerivation rec {
    pname = "nodejs-official";
    version = "24.21.0";

    src = pkgs.fetchurl {
      url = "https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.xz";
      hash = "sha256-/Y5Z1aURUQ9qKYr7VI8Yx9KxvkBNi0on2U++SfVsstY=";
    };

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    dontPatchELF = true;
    dontPatchShebangs = true;

    installPhase = ''
      mkdir -p $out
      cp -r . $out/
      chmod +x $out/bin/node $out/bin/npm $out/bin/npx
    '';

    meta = {
      description = "Official Node.js binary distribution (for DSH)";
      homepage = "https://nodejs.org/";
      platforms = [ "x86_64-linux" ];
    };
  };

  # DSH is still a developer preview; keep the npm package pinned rather than
  # building the whole pnpm monorepo here. First run needs network.
  dsh = pkgs.writeShellApplication {
    name = "dsh";
    runtimeInputs = [
      nodejs
      pkgs.git
    ];
    text = ''
      # Use the explicitly selected official Node, not whatever npx happens
      # to resolve from PATH.
      exec ${nodejs}/bin/npx --yes @deepseek-ai/dsh@0.2.1-rc.5 "$@"
    '';
  };
in
{
  home.packages = [ dsh ];
}
