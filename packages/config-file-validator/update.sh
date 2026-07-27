#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd "$script_dir/../.." && pwd)
cd "$script_dir"

current_version=$(awk -F '"' '/^  version = / { print $2; exit }' package.nix)
api_payload=$(curl -fsSL https://api.github.com/repos/Boeing/config-file-validator/releases/latest || true)
latest_version=$(printf '%s' "$api_payload" | jq -r .tag_name 2>/dev/null || true)
if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
  latest_version=$(git ls-remote --tags --refs https://github.com/Boeing/config-file-validator.git |
    awk -F/ '{print $NF}' |
    sed 's/^v//' |
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' |
    sort -V |
    tail -n 1)
fi
latest_version=${latest_version#v}
if [ -z "$latest_version" ]; then
  echo "could not determine latest config-file-validator version" >&2
  exit 1
fi

if [ "$current_version" = "$latest_version" ]; then
  echo "config-file-validator already at $current_version"
  exit 0
fi

echo "Updating config-file-validator from $current_version to $latest_version"

source_nix_hash=$(nix-prefetch-url --type sha256 --unpack "https://github.com/Boeing/config-file-validator/archive/refs/tags/v${latest_version}.tar.gz")
source_hash=$(nix hash convert --hash-algo sha256 --to sri "$source_nix_hash")

tmp_dir=$(mktemp -d)
cp package.nix "$tmp_dir/package.nix"
updated=false
cleanup_tmp() {
  if [ "$updated" != true ]; then
    cp "$tmp_dir/package.nix" package.nix
  fi
  trash "$tmp_dir" || true
}
trap cleanup_tmp EXIT

awk -v version="$latest_version" -v source_hash="$source_hash" '
  /^  version = / { sub(/^  version = "[^"]+";/, "  version = \"" version "\";") }
  /^    hash = / { sub(/^    hash = "[^"]+";/, "    hash = \"" source_hash "\";") }
  /^  vendorHash = / { sub(/^  vendorHash = "[^"]+";/, "  vendorHash = \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\";") }
  { print }
' package.nix > "$tmp_dir/package.nix.new"
mv "$tmp_dir/package.nix.new" package.nix

nix build "$repo_dir#config-file-validator" --no-link > "$tmp_dir/build.log" 2>&1 || true
vendor_hash=$(awk '/got:/ { print $2; exit }' "$tmp_dir/build.log")
if [ -z "$vendor_hash" ]; then
  echo "could not parse vendorHash for config-file-validator $latest_version" >&2
  cat "$tmp_dir/build.log" >&2
  exit 1
fi

awk -v vendor_hash="$vendor_hash" '
  /^  vendorHash = / { sub(/^  vendorHash = "[^"]+";/, "  vendorHash = \"" vendor_hash "\";") }
  { print }
' package.nix > "$tmp_dir/package.nix.new"
mv "$tmp_dir/package.nix.new" package.nix
updated=true

echo "updated config-file-validator to $latest_version"
