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
  pname = "lat-md";
  version = data.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/lat.md/-/lat.md-${data.version}.tgz";
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

  meta = with lib; {
    description = "Knowledge graph for codebases, written in markdown";
    homepage = "https://github.com/1st1/lat.md";
    license = licenses.mit;
    mainProgram = "lat";
    platforms = platforms.unix;
  };
}
