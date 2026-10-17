{
  callPackage,
  runCommand,
}:

let
  lat = callPackage ../lat-md/package.nix { };
in
runCommand "lat-md-pi-devenv-${lat.version}"
  {
    inherit (lat) version;
    meta = {
      description = "Upstream Lat CLI and Pi coding agent integration for devenv";
      inherit (lat.meta) homepage license platforms;
      mainProgram = "lat";
    };
  }
  ''
    templates="${lat}/lib/node_modules/lat.md/templates"
    mkdir -p "$out/bin"
    ln -s ${lat}/bin/lat "$out/bin/lat"
    ln -s "$templates/skill" "$out/skill"
    substitute "$templates/pi-extension.ts" "$out/extension.ts" \
      --replace-fail '__LAT_INVOCATION__' '{"command":"${lat}/bin/lat","args":[]}'
    for file in extension.ts skill/SKILL.md; do
      test -s "$out/$file"
    done
    "$out/bin/lat" --version | grep -F '${lat.version}'
  ''
