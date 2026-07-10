#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

repo="backnotprop/plannotator"
hashes_file="hashes.json"

latest_tag=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name // empty')
current_version=$(jq -r '.version' "$hashes_file")

if [ -z "$latest_tag" ] || [ "$latest_tag" = "null" ]; then
  echo "could not read latest release tag for ${repo}" >&2
  exit 1
fi

latest_version="${latest_tag#v}"

if [ "$current_version" = "$latest_version" ]; then
  echo "plannotator already at ${current_version}"
  exit 0
fi

fetch_hash() {
  local asset_name=$1
  local url="https://github.com/${repo}/releases/download/${latest_tag}/${asset_name}"

  local raw
  raw=$(nix-prefetch-url --type sha256 "$url")
  nix hash convert --hash-algo sha256 --to sri "$raw"
}

darwin_arm64_hash=$(fetch_hash "plannotator-darwin-arm64")
darwin_x64_hash=$(fetch_hash "plannotator-darwin-x64")
linux_arm64_hash=$(fetch_hash "plannotator-linux-arm64")
linux_x64_hash=$(fetch_hash "plannotator-linux-x64")

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
  --arg darwin_x64 "$darwin_x64_hash" \
  --arg linux_arm64 "$linux_arm64_hash" \
  --arg linux_x64 "$linux_x64_hash" \
  '{
    version: $version,
    hashes: {
      "darwin-arm64": $darwin_arm64,
      "darwin-x64": $darwin_x64,
      "linux-arm64": $linux_arm64,
      "linux-x64": $linux_x64
    }
  }' \
  > "$tmp_file"

mv "$tmp_file" "$hashes_file"

echo "updated plannotator to ${latest_version}"
