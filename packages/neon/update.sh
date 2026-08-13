#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

package_name="neon"
hashes_file="hashes.json"
lock_file="package-lock.json"

current_version=$(jq -r '.version' "$hashes_file")
latest_version=$(npm view "$package_name" version)

if [ "$current_version" = "$latest_version" ]; then
  echo "neon already at $current_version"
  exit 0
fi

echo "Updating neon from $current_version to $latest_version"

source_nix_hash=$(nix-prefetch-url --type sha256 "https://registry.npmjs.org/${package_name}/-/${package_name}-${latest_version}.tgz")
source_hash=$(nix hash convert --hash-algo sha256 --to sri "$source_nix_hash")

tmp_dir=$(mktemp -d)
cleanup_tmp() {
  if [ -n "${tmp_dir:-}" ] && [ -e "$tmp_dir" ]; then
    trash "$tmp_dir" || true
  fi
}
trap cleanup_tmp EXIT

(
  cd "$tmp_dir"
  pack_file="$(npm pack "${package_name}@${latest_version}" | tail -n1)"
  tar -xzf "$pack_file"
  cd package
  npm pkg delete devDependencies
  npm install --package-lock-only --ignore-scripts --omit=dev >/tmp/neon-install.log 2>&1
)

if command -v prefetch-npm-deps >/dev/null 2>&1; then
  npm_deps_hash=$(prefetch-npm-deps "$tmp_dir/package/package-lock.json")
else
  npm_deps_hash=$(nix run github:NixOS/nixpkgs#prefetch-npm-deps -- "$tmp_dir/package/package-lock.json")
fi

cp "$tmp_dir/package/package-lock.json" "$lock_file"

cat > "$hashes_file.tmp" <<EOF
{
  "version": "$latest_version",
  "sourceHash": "$source_hash",
  "npmDepsHash": "$npm_deps_hash"
}
EOF
mv "$hashes_file.tmp" "$hashes_file"

echo "updated neon to $latest_version"
