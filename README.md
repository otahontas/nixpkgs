# nixpkgs

Personal collection of tools packaged for Nix, primarily used through devenv and Home Manager.

## Packages

- `absurdctl`
- `auth0-deploy-cli` (`a0deploy`)
- `config-file-validator` (`cfv`)
- `effect-tsgo`
- `lat-md` (`lat`)
- `lat-md-pi-devenv`
- `neon`
- `plannotator`
- `resend-cli` (`resend`)

## Lat Pi integration patches

`lat-md` packages the upstream release without changing its Pi template. The
`lat-md-pi-devenv` bundle applies two explicit patches to its generated extension:

- [`pi-capture-stderr.patch`](packages/lat-md-pi-devenv/patches/pi-capture-stderr.patch)
  captures CLI stderr instead of writing status messages over Pi's terminal UI.
- [`pi-sync-file-types.patch`](packages/lat-md-pi-devenv/patches/pi-sync-file-types.patch)
  includes Nix, shell, Fish, and Lua files in the documentation-sync reminder.

The skill and CLI remain unchanged. Patches are applied without fuzzy matching;
review them against the upstream template when upgrading Lat.
