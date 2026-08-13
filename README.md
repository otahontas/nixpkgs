# nixpkgs

Personal Nix package collection for small tools.

## Packages

Each `packages/<name>/package.nix` file becomes:

- `packages.${system}.<name>`
- `pkgs.<name>` when you apply `overlays.default`

Current packages:

- `absurdctl`
- `config-file-validator`
- `lat-md`
- `neon`
- `plannotator`
- `resend-cli` (`resend`)

## Use from another flake

```nix
inputs.otahontas-nixpkgs.url = "github:otahontas/nixpkgs";

# Packages
otahontas-nixpkgs.packages.${system}.absurdctl
otahontas-nixpkgs.packages.${system}.config-file-validator
otahontas-nixpkgs.packages.${system}.lat-md
otahontas-nixpkgs.packages.${system}.neon
otahontas-nixpkgs.packages.${system}.plannotator
otahontas-nixpkgs.packages.${system}.resend-cli

# Overlay
nixpkgs.overlays = [ otahontas-nixpkgs.overlays.default ];
```
