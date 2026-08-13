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
  pname = "auth0-deploy-cli";
  version = data.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/auth0-deploy-cli/-/auth0-deploy-cli-${data.version}.tgz";
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
    test -x "$out/bin/a0deploy"
    "$out/bin/a0deploy" --version | grep -F "${data.version}"
  '';

  meta = with lib; {
    description = "CLI for deploying updates to an Auth0 tenant";
    homepage = "https://github.com/auth0/auth0-deploy-cli";
    changelog = "https://github.com/auth0/auth0-deploy-cli/blob/v${data.version}/CHANGELOG.md";
    downloadPage = "https://www.npmjs.com/package/auth0-deploy-cli";
    license = licenses.mit;
    mainProgram = "a0deploy";
    platforms = platforms.all;
  };
}
