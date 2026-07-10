{
  lib,
  fetchurl,
  stdenvNoCC,
}:

let
  data = lib.importJSON ./hashes.json;
  version = data.version;
  platform = {
    aarch64-darwin = "darwin-arm64";
    x86_64-darwin = "darwin-x64";
    aarch64-linux = "linux-arm64";
    x86_64-linux = "linux-x64";
  }.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "plannotator";
  inherit version;

  src = fetchurl {
    url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-${platform}";
    hash = data.hashes.${platform};
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm755 "$src" "$out/bin/plannotator"
  '';

  meta = with lib; {
    description = "Cross-platform annotation CLI tool";
    homepage = "https://github.com/backnotprop/plannotator";
    license = licenses.asl20;
    mainProgram = "plannotator";
    platforms = platforms.unix;
  };
}
