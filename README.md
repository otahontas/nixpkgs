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
inputs.personal-nixpkgs.url = "github:otahontas/nixpkgs";

# Packages
personal-nixpkgs.packages.${system}.config-file-validator
personal-nixpkgs.packages.${system}.neonctl
personal-nixpkgs.packages.${system}.resend-cli

# Overlay
nixpkgs.overlays = [ personal-nixpkgs.overlays.default ];
```
