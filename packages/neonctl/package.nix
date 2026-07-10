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
  pname = "neonctl";
  version = data.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/neon/-/neon-${data.version}.tgz";
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
    test -x "$out/bin/neonctl"
    test -x "$out/bin/neon"
    "$out/bin/neonctl" --version | grep -F "${data.version}"
    "$out/bin/neon" --version | grep -F "${data.version}"
  '';

  meta = with lib; {
    description = "Neon database CLI";
    homepage = "https://github.com/neondatabase/neon-pkgs";
    changelog = "https://github.com/neondatabase/neon-pkgs/releases?q=neon";
    downloadPage = "https://www.npmjs.com/package/neon";
    license = licenses.asl20;
    mainProgram = "neonctl";
    platforms = platforms.all;
  };
}
