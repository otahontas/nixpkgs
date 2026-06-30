#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

json=$(curl -fsSL https://pypi.org/pypi/absurdctl/json)
version=$(printf '%s' "$json" | jq -er '.info.version')

if ! sha256_hex=$(
  printf '%s' "$json" | jq -er --arg version "$version" '
    first(
      .releases[$version][]?
      | select(.packagetype == "bdist_wheel")
      | select(.filename == ("absurdctl-" + $version + "-py3-none-any.whl"))
      | select((.yanked // false) == false)
      | .digests.sha256
    ) // empty
  '
); then
  echo "could not find non-yanked py3-none-any wheel for absurdctl $version" >&2
  exit 1
fi

if ! printf '%s\n' "$sha256_hex" | grep -Eq '^[0-9a-f]{64}$'; then
  echo "invalid PyPI sha256 for absurdctl $version: $sha256_hex" >&2
  exit 1
fi

source_hash=$(nix hash convert --hash-algo sha256 --to sri "$sha256_hex")
tmp=$(mktemp "${PWD}/hashes.json.tmp.XXXXXX")

cleanup_tmp() {
  if [ -n "${tmp:-}" ] && [ -e "$tmp" ]; then
    if command -v trash >/dev/null 2>&1; then
      trash "$tmp" || true
    fi
  fi
}
trap cleanup_tmp EXIT

jq -n \
  --arg version "$version" \
  --arg sourceHash "$source_hash" \
  '{ version: $version, sourceHash: $sourceHash }' \
  > "$tmp"
chmod 644 "$tmp"

mv "$tmp" hashes.json
