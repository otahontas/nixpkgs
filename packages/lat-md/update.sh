#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

repo="1st1/lat.md"
hashes_file="hashes.json"

latest_tag=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name // empty')
current_version=$(jq -r '.version' "$hashes_file")

if [ -z "$latest_tag" ] || [ "$latest_tag" = "null" ]; then
  echo "could not read latest release tag for ${repo}" >&2
  exit 1
fi

latest_version="${latest_tag#v}"

if [ "$current_version" = "$latest_version" ]; then
  echo "lat-md already at ${current_version}"
  exit 0
fi

source_url="https://github.com/${repo}/archive/refs/tags/${latest_tag}.tar.gz"
source_nix_hash=$(nix-prefetch-url --type sha256 "$source_url")
source_hash=$(nix hash convert --hash-algo sha256 --to sri "$source_nix_hash")

tmp_dir=$(mktemp -d)
tmp_file=$(mktemp "${PWD}/hashes.json.tmp.XXXXXX")

cleanup_tmp() {
  if [ -n "${tmp_file:-}" ] && [ -e "$tmp_file" ]; then
    trash "$tmp_file" || true
  fi

  if [ -n "${tmp_dir:-}" ] && [ -e "$tmp_dir" ]; then
    trash -rf "$tmp_dir" || true
  fi
}

trap cleanup_tmp EXIT

curl -fsSL "$source_url" -o "$tmp_dir/source.tar.gz"

tar -xzf "$tmp_dir/source.tar.gz" -C "$tmp_dir"
source_dir_name=$(tar -tf "$tmp_dir/source.tar.gz" | head -n 1 | cut -d/ -f1)
source_dir="$tmp_dir/$source_dir_name"
lockfile="$source_dir/pnpm-lock.yaml"

current_pnpm_deps_hash=$(jq -r '.pnpmDepsHash' "$hashes_file")
pnpm_deps_hash="$current_pnpm_deps_hash"

if [ -f "$lockfile" ] && command -v prefetch-npm-deps >/dev/null 2>&1; then
  if computed=$(prefetch-npm-deps "$lockfile" 2>/tmp/prefetch-npm-deps.log); then
    if [ -n "$computed" ]; then
      pnpm_deps_hash="$computed"
    fi
  else
    echo "warning: prefetch-npm-deps failed, keeping existing pnpmDepsHash" >&2
  fi
elif [ ! -f "$lockfile" ]; then
  echo "warning: lockfile not found in ${source_dir_name}, keeping existing pnpmDepsHash" >&2
fi


jq -n \
  --arg version "$latest_version" \
  --arg sourceHash "$source_hash" \
  --arg npmDepsHash "$pnpm_deps_hash" \
  '{
    version: $version,
    sourceHash: $sourceHash,
    pnpmDepsHash: $npmDepsHash
  }' \
  > "$tmp_file"

mv "$tmp_file" "$hashes_file"

echo "updated lat-md to ${latest_version}"
