# nixpkgs

Personal collection of tools packaged for Nix, primarily used through devenv and Home Manager.

## Packages

- `absurdctl`
- `auth0-deploy-cli` (`a0deploy`)
- `config-file-validator` (`cfv`)
- `effect-tsgo`
- `impeccable` (native engine)
- `impeccable-pi-devenv` ([project-local Pi setup](packages/impeccable-pi-devenv/README.md))
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

These integration patches leave the skill and CLI unchanged. They are applied
without fuzzy matching; review them against the upstream template when upgrading Lat.

The CLI package separately applies
[`ui-writable-assets.patch`](packages/lat-md/patches/ui-writable-assets.patch)
to make copied UI assets writable before building a published site. Nix Store
permissions otherwise survive the copy and prevent asset rewrites and cleanup.
Only output copies are changed; the package's source assets remain read-only.
