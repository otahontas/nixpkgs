{ inputs, pkgs, ... }:

let
  integration = inputs.otahontas-nixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.impeccable-pi-devenv;
in
{
  scripts.impeccable.exec = ''
    exec "$DEVENV_ROOT/.devenv/impeccable/bin/impeccable" "$@"
  '';

  tasks."impeccable:setup" = {
    before = [ "devenv:enterShell" ];
    exec = ''
      set -eu
      cd "$DEVENV_ROOT"
      mkdir -p .devenv .pi/skills
      skill=.pi/skills/impeccable
      target=../../.devenv/impeccable/skill

      # Do not silently overwrite a checked-in skill or an unrelated symlink.
      if [ -e "$skill" ] || [ -L "$skill" ]; then
        if [ ! -L "$skill" ] || [ "$(${pkgs.coreutils}/bin/readlink "$skill")" != "$target" ]; then
          echo "impeccable: $skill already exists and is not managed by this module" >&2
          exit 1
        fi
      fi
      for pointer in .devenv/impeccable .devenv/impeccable.next; do
        if [ -e "$pointer" ] && [ ! -L "$pointer" ]; then
          echo "impeccable: refusing to replace non-symlink $pointer" >&2
          exit 1
        fi
      done

      # Build before switching the single bundle pointer; failed setup keeps the old bundle.
      test -x ${integration}/bin/impeccable
      if [ ! -L "$skill" ]; then
        ${pkgs.coreutils}/bin/ln -s "$target" "$skill"
      fi
      ${pkgs.coreutils}/bin/ln -sfnT ${integration} .devenv/impeccable.next
      ${pkgs.coreutils}/bin/mv -Tf .devenv/impeccable.next .devenv/impeccable
    '';
  };
}
