{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
}:

let
  data = lib.importJSON ./hashes.json;
in
buildNpmPackage {
  pname = "effect-tsgo";
  version = data.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@effect/tsgo/-/tsgo-${data.version}.tgz";
    hash = data.sourceHash;
  };

  inherit nodejs;
  npmDepsHash = data.npmDepsHash;
  npmFlags = [ "--ignore-scripts" ];
  npmInstallFlags = [ "--omit=dev" ];
  dontNpmBuild = true;

  postPatch = ''
    awk '
      BEGIN { skip = 0; depth = 0; prev = "" }
      /"devDependencies"[[:space:]]*:[[:space:]]*\{/ { skip = 1; depth = 1; next }
      skip {
        depth += gsub(/\{/, "{") - gsub(/\}/, "}")
        if (depth <= 0) skip = 0
        next
      }
      {
        if ($0 ~ /^}/ && prev ~ /,$/) sub(/,$/, "", prev)
        if (prev != "") print prev
        prev = $0
      }
      END { if (prev != "") print prev }
    ' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    test -x "$out/bin/effect-tsgo"
    "$out/bin/effect-tsgo" --version | grep -F "${data.version}"
  '';

  meta = with lib; {
    description = "Effect Language Service for TypeScript-Go";
    homepage = "https://github.com/Effect-TS/tsgo";
    changelog = "https://github.com/Effect-TS/tsgo/releases";
    downloadPage = "https://www.npmjs.com/package/@effect/tsgo";
    license = licenses.mit;
    mainProgram = "effect-tsgo";
    platforms = platforms.all;
  };
}
