# Flakes

Nix package tap for small tools.

## Packages

Each `packages/<name>/package.nix` file becomes:

- `packages.${system}.<name>`
- `pkgs.<name>` when you apply `overlays.default`

Current packages:

- `config-file-validator`
- `neonctl` (`neonctl`, `neon`)
- `resend-cli` (`resend`)

## Use from another flake

```nix
inputs.package-tap.url = "github:otahontas/flakes";

# Packages
package-tap.packages.${system}.config-file-validator
package-tap.packages.${system}.neonctl
package-tap.packages.${system}.resend-cli

# Overlay
nixpkgs.overlays = [ package-tap.overlays.default ];
```
