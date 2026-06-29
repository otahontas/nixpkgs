# nixpkgs

Personal Nix package collection for small tools.

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
inputs.otahontas-nixpkgs.url = "github:otahontas/nixpkgs";

# Packages
otahontas-nixpkgs.packages.${system}.config-file-validator
otahontas-nixpkgs.packages.${system}.neonctl
otahontas-nixpkgs.packages.${system}.resend-cli

# Overlay
nixpkgs.overlays = [ otahontas-nixpkgs.overlays.default ];
```
