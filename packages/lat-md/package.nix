{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
}:

let
  data = lib.importJSON ./hashes.json;
  version = data.version;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lat-md";
  inherit version;

  src = fetchFromGitHub {
    owner = "1st1";
    repo = "lat.md";
    tag = "v${version}";
    hash = data.sourceHash;
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = data.pnpmDepsHash;
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    pnpm prune --prod
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/node_modules/lat.md" "$out/bin"
    cp -R dist templates package.json node_modules "$out/lib/node_modules/lat.md/"
    makeWrapper ${nodejs}/bin/node "$out/bin/lat" \
      --add-flags "$out/lib/node_modules/lat.md/dist/src/cli/index.js"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Knowledge graph for codebases, written in markdown";
    homepage = "https://github.com/1st1/lat.md";
    license = licenses.mit;
    mainProgram = "lat";
    platforms = platforms.unix;
  };
})
