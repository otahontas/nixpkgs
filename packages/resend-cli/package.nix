{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  data = lib.importJSON ./hashes.json;
in
buildNpmPackage {
  pname = "resend-cli";
  version = data.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/resend-cli/-/resend-cli-${data.version}.tgz";
    hash = data.sourceHash;
  };

  nodejs = nodejs_22;
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
    test -x "$out/bin/resend"
    "$out/bin/resend" --version | grep -F "${data.version}"
  '';

  meta = with lib; {
    description = "Resend CLI";
    homepage = "https://github.com/resend/resend-cli";
    changelog = "https://github.com/resend/resend-cli/releases";
    downloadPage = "https://www.npmjs.com/package/resend-cli";
    license = licenses.mit;
    mainProgram = "resend";
    platforms = platforms.all;
  };
}
