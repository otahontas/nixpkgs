{ inputs, pkgs, ... }:

let
  integration = inputs.otahontas-nixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.lat-md-pi-devenv;
in
{
  scripts.lat.exec = ''
    exec "$DEVENV_ROOT/.devenv/lat-md/bin/lat" "$@"
  '';

  tasks."lat-md:setup" = {
    before = [ "devenv:enterShell" ];
    exec = ''
      set -eu
      cd "$DEVENV_ROOT"
      mkdir -p .devenv .pi/extensions .pi/skills/lat-md
      ${pkgs.coreutils}/bin/ln -sfnT ../../.devenv/lat-md/extension.ts .pi/extensions/lat.ts
      ${pkgs.coreutils}/bin/ln -sfnT ../../../.devenv/lat-md/skill/SKILL.md .pi/skills/lat-md/SKILL.md
      ${pkgs.coreutils}/bin/ln -sfnT ${integration} .devenv/lat-md.next
      ${pkgs.coreutils}/bin/mv -Tf .devenv/lat-md.next .devenv/lat-md
    '';
  };
}
