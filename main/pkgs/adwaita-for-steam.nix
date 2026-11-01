{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  writeShellScript,
}:

let
  # The installer writes into the skin tree and resolves ADW_ROOT relative to
  # its working directory. The Nix store is read-only, so run it from a
  # writable temporary copy instead of from $out directly.
  installer = writeShellScript "adwaita-for-steam" ''
    set -euo pipefail

    self=$(readlink -f "$0")
    share=$(dirname "$(dirname "$self")")/share/adwaita-for-steam

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    cp -r "$share/." "$tmp/"
    chmod -R u+w "$tmp"
    cd "$tmp"

    ${python3}/bin/python3 ./install.py "$@"
  '';
in
stdenvNoCC.mkDerivation {
  pname = "adwaita-for-steam";
  version = "4.4-unstable-2026-07-29";

  src = fetchFromGitHub {
    owner = "tkashkin";
    repo = "Adwaita-for-Steam";
    rev = "1e92107a51f6ed53c59c38646444c9eb3a52b030";
    hash = "sha256-wH0z2LZ94j5ErRI40f9IRBJXJ6yuL+NLgjmj9G8odxU=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/adwaita-for-steam
    cp -r adwaita scripts install.py skin.json theme.json LICENSE README.md \
      $out/share/adwaita-for-steam/

    install -Dm755 ${installer} $out/bin/adwaita-for-steam

    runHook postInstall
  '';

  meta = {
    description = "Adwaita skin for the Steam client, with the upstream CLI installer";
    homepage = "https://github.com/tkashkin/Adwaita-for-Steam";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "adwaita-for-steam";
  };
}
