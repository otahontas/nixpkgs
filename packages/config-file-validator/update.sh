#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

repo="Boeing/config-file-validator"
hashes_file="hashes.json"

current_version=$(jq -r '.version' "$hashes_file")
api_payload=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" || true)
latest_version=$(printf '%s' "$api_payload" | jq -r .tag_name 2>/dev/null || true)
if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
  latest_version=$(git ls-remote --tags --refs "https://github.com/${repo}.git" |
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

fetch_hash() {
  local platform=$1
  local url="https://github.com/${repo}/releases/download/v${latest_version}/cfv-${latest_version}-${platform}.tar.gz"

  local raw
  raw=$(nix-prefetch-url --type sha256 "$url")
  nix hash convert --hash-algo sha256 --to sri "$raw"
}

darwin_arm64_hash=$(fetch_hash "darwin-arm64")
linux_arm64_hash=$(fetch_hash "linux-arm64")
linux_amd64_hash=$(fetch_hash "linux-amd64")

tmp_file=$(mktemp "${PWD}/hashes.json.tmp.XXXXXX")
cleanup_tmp() {
  if [ -n "${tmp_file:-}" ] && [ -e "$tmp_file" ]; then
    trash "$tmp_file" || true
  fi
}
trap cleanup_tmp EXIT

jq -n \
  --arg version "$latest_version" \
  --arg darwin_arm64 "$darwin_arm64_hash" \
  --arg linux_arm64 "$linux_arm64_hash" \
  --arg linux_amd64 "$linux_amd64_hash" \
  '{
    version: $version,
    hashes: {
      "darwin-arm64": $darwin_arm64,
      "linux-arm64": $linux_arm64,
      "linux-amd64": $linux_amd64
    }
  }' \
  > "$tmp_file"
chmod 644 "$tmp_file"

mv "$tmp_file" "$hashes_file"

echo "updated config-file-validator to ${latest_version}"
