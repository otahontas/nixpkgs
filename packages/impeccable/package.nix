{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.1.11";
  sources = {
    aarch64-darwin = {
      platform = "darwin-arm64";
      sha256 = "7427918d6e75507401a1b7b691eefe58a7c01a2fc63b712016ffc5a0ac1c05e6";
    };
    x86_64-linux = {
      platform = "linux-x64";
      sha256 = "0221607e1f535af937ea267c347b1f90233b85dc2563cbd2eeefdf42e0e5c594";
    };
    aarch64-linux = {
      platform = "linux-arm64";
      sha256 = "a3036c5c2da08ac6a14fa4886e96a8b1651beab332af75cbe328092528d6e40a";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "impeccable";
  inherit version;

  src = fetchurl {
    url = "https://github.com/pbakaus/impeccable/releases/download/engine-v${version}/impeccable-${source.platform}";
    inherit (source) sha256;
  };

  dontUnpack = true;
  # Upstream Linux releases target musl and do not need an FHS interpreter.
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/impeccable"
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/impeccable" engine-probe | grep -Fx 'impeccable-engine ${version}'
    runHook postInstallCheck
  '';

  meta = {
    description = "Native Impeccable design workflow engine";
    homepage = "https://github.com/pbakaus/impeccable";
    license = lib.licenses.asl20;
    mainProgram = "impeccable";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
