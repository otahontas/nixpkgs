# Project-local Impeccable for Pi

A devenv module that installs Impeccable only in the repository that imports it.
The bundle pins skill **4.5.0** and native engine **0.1.11** together. It supports
`aarch64-darwin`, `x86_64-linux`, and `aarch64-linux`.

## Enable in a repository

Add the collection input and module import to `devenv.yaml` (merge with any
existing inputs and imports):

```yaml
inputs:
  otahontas-nixpkgs:
    url: github:otahontas/nixpkgs
imports:
  - otahontas-nixpkgs/packages/impeccable-pi-devenv
```

Add the generated resources to the repository's `.gitignore`:

```gitignore
/.devenv/
/.pi/skills/impeccable
```

Commit `devenv.yaml`, `devenv.nix`, `devenv.lock`, and the ignore rule. The lock
pins the collection revision; another supported machine gets the same bundle.
An existing devenv project can retain its own nixpkgs input.

Enter the environment and start your separately installed Pi:

```sh
devenv shell
pi
```

Grant project trust if Pi asks, then use `/skill:impeccable`. Restart Pi or run
`/reload` after activation or an update. The shell also exposes
`impeccable engine-probe` and the other engine commands.

Remove or disable any globally installed Impeccable skill before relying on
the project skill: Pi keeps the first skill with a given name, and a global
skill can mask the project copy. This module never changes global Pi settings.

## Managed resources and isolation

The `impeccable:setup` task runs before `devenv:enterShell`. It creates:

```text
.devenv/impeccable -> /nix/store/…-impeccable-pi-devenv-4.5.0
.pi/skills/impeccable -> ../../.devenv/impeccable/skill
```

One atomic bundle-pointer replacement keeps references, scripts, and engine
together. A failed build leaves the old pointer active. Setup is repeatable
and refuses to replace an existing unmanaged skill or a non-symlink bundle
pointer; move such resources aside explicitly before enabling the module.

The full upstream skill and supporting files are bundled, but its Unix
launcher is replaced with a Nix-specific launcher that always selects the
pinned engine and skill resources. It overrides inherited `IMPECCABLE_BIN`,
`IMPECCABLE_SKILL_DIR`, and `IMPECCABLE_SELF` rather than using global caches,
PATH discovery, or first-use downloads. The bundle's CLI uses that same launcher.
Changing the shell's `IMPECCABLE_BIN` does not change the selected engine.

The Nix Store copy is immutable. Use Nix input updates, not `impeccable update`
or `impeccable install`, to manage this skill. Run commands with the project as
the working directory so project context and generated artifacts belong to
that repository.

Activation does not initialize `PRODUCT.md`, `DESIGN.md`, or surface briefs,
enable edit hooks, install Pi, or configure image-generation providers. Project
documents and sidecars created during ordinary use remain writable project
files and should be versioned according to the project's own policy. Browser,
image-generation, and other tools requested by a workflow are separate
capabilities, not supplied by this module.

## Update or remove

Update the collection input with `devenv update otahontas-nixpkgs`, enter the
shell again, and reload Pi. Skill and engine pins live in the two package
definitions; the bundle build checks the skill's engine requirement before it
can activate.

To stop using the module, remove its import and, if unused, the collection
input. Remove the generated `.pi/skills/impeccable` and `.devenv/impeccable`
symlinks explicitly, then reload Pi. The module does not auto-delete resources
when its import is removed, and it never deletes project design documents.
