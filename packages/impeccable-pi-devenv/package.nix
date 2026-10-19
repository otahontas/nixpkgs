{
  lib,
  callPackage,
  fetchzip,
  runCommand,
  runtimeShell,
}:

let
  engine = callPackage ../impeccable/package.nix { };
  version = "4.5.0";
  bundle = fetchzip {
    url = "https://github.com/pbakaus/impeccable/releases/download/skill-v${version}/universal.zip";
    hash = "sha256-+gh8Bv7bhY36udcbMUODKj1JZtS0R0rGPNbgeXoQBYI=";
    stripRoot = false;
  };
in
runCommand "impeccable-pi-devenv-${version}"
  {
    inherit version;
    passthru.engineVersion = engine.version;
    meta = {
      description = "Pinned Impeccable skill and engine for project-local Pi use through devenv";
      inherit (engine.meta) homepage license platforms;
      mainProgram = "impeccable";
    };
  }
  ''
    mkdir -p "$out/bin"
    cp -R ${bundle}/.pi/skills/impeccable "$out/skill"
    chmod -R u+w "$out/skill"

    # Fail the build if upstream's expected skill layout or engine pin drifts.
    for file in SKILL.md reference/new-work.md scripts/command-metadata.json scripts/VERSION; do
      test -s "$out/skill/$file"
    done
    test "$(tr -d '[:space:]' < "$out/skill/scripts/VERSION")" = '${engine.version}'
    grep -Fx 'version: ${version}' "$out/skill/SKILL.md"

    # Nix integration: replace the downloading launcher with an immutable pair.
    # Do not inherit a global Pi wrapper's IMPECCABLE_BIN or another skill's refs.
    cat > "$out/skill/scripts/impeccable" <<EOF
    #!${runtimeShell}
    # Nix-packaged launcher; skill content and engine are pinned together.
    export IMPECCABLE_BIN="${engine}/bin/impeccable"
    export IMPECCABLE_SKILL_DIR="$out/skill"
    export IMPECCABLE_SELF="\$0"
    exec "${engine}/bin/impeccable" "\$@"
    EOF
    chmod +x "$out/skill/scripts/impeccable"
    ln -s ../skill/scripts/impeccable "$out/bin/impeccable"
    "$out/bin/impeccable" engine-probe | grep -Fx 'impeccable-engine ${engine.version}'
  ''
