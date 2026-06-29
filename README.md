# Flakes

Nix package tap for small tools and Pi extensions.

## Packages

Each `packages/<name>/package.nix` file becomes:

- `packages.${system}.<name>`
- `pkgs.<name>` when you apply `overlays.default`

Current packages:

- `config-file-validator`
- `pi-mcp-adapter`
- `pi-ralph-loop`
- `pi-subagents`
- `pi-web-access`

## Use from another flake

```nix
inputs.package-tap.url = "github:otahontas/flakes";

# Packages
package-tap.packages.${system}.config-file-validator
package-tap.packages.${system}.pi-mcp-adapter
package-tap.packages.${system}.pi-web-access
package-tap.packages.${system}.pi-subagents
package-tap.packages.${system}.pi-ralph-loop

# Overlay
nixpkgs.overlays = [ package-tap.overlays.default ];
```

Pi extension packages build to Pi package roots. Home Manager can symlink each output into `~/.pi/agent/extensions/<package>`.
