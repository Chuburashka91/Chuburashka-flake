{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname = "share-tech-mono";
  version = "1.003";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/google/fonts/1b86e1e716445daccc346253911955073b0d254a/ofl/sharetechmono/ShareTechMono-Regular.ttf";
    hash = "sha256-nOqx+HQUgpryWcD1N1c64D733TFHwLJ6NqGgvrZzJnc=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 "$src" "$out/share/fonts/truetype/ShareTechMono-Regular.ttf"
    runHook postInstall
  '';

  meta = {
    description = "Share Tech Mono, a monospaced programming font";
    homepage = "https://fonts.google.com/specimen/Share+Tech+Mono";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
