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
    aarch64-linux = "linux-arm64";
    x86_64-linux = "linux-amd64";
  }.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "config-file-validator";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Boeing/config-file-validator/releases/download/v${version}/cfv-${version}-${platform}.tar.gz";
    hash = data.hashes.${platform};
  };

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    install -Dm755 cfv "$out/bin/cfv"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    test -x "$out/bin/cfv"
    "$out/bin/cfv" --version | grep -F "${version}"
  '';

  meta = {
    description = "CLI for validating configuration files";
    homepage = "https://github.com/Boeing/config-file-validator";
    changelog = "https://github.com/Boeing/config-file-validator/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = "cfv";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
