#!/usr/bin/env bash
set -euo pipefail

# Path to the Waterfox Nix expression
NIX_FILE="waterfox.nix"

# Function to get the latest Waterfox version
get_latest_version() {
  echo "Fetching latest Waterfox version..."

  # Extract version from the download page
  VERSION_RAW=$(curl -s "https://www.waterfox.net/download/" | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+ (Latest)' | head -n 1)

  if [[ -z "$VERSION_RAW" ]]; then
    echo "Error: Could not determine the latest Waterfox version."
    exit 1
  fi

  # Extract just the version number
  VERSION_NUMBER=$(echo "$VERSION_RAW" | sed 's/ (Latest)//')

  # Waterfox G-series prefix
  LATEST_VERSION="G$VERSION_NUMBER"

  echo "Latest version: $LATEST_VERSION"
  return 0
}

# Function to update the Nix expression
update_nix_expression() {
  local version="$1"
  local tarball_url="https://cdn1.waterfox.net/waterfox/releases/${version}/Linux_x86_64/waterfox-${version}.en-US.linux-x86_64.tar.bz2"

  echo "Fetching tarball hash for $tarball_url..."
  local hash=$(nix-prefetch-url "$tarball_url" --type sha256)

  if [[ -z "$hash" ]]; then
    echo "Error: Could not fetch hash for the tarball."
    exit 1
  fi

  echo "Updating Nix expression..."
  # Update version in the Nix expression
  sed -i "s/version = \"[^\"]*\";/version = \"${version}\";/" "$NIX_FILE"

  # Update URL in the Nix expression
  sed -i "s|url = \"https://cdn1.waterfox.net/waterfox/releases/[^\"]*\";|url = \"${tarball_url}\";|" "$NIX_FILE"

  # Update hash in the Nix expression
  sed -i "s/sha256 = \"[^\"]*\";/sha256 = \"${hash}\";/" "$NIX_FILE"

  echo "Successfully updated $NIX_FILE to Waterfox version $version"
}

main() {
  if [[ ! -f "$NIX_FILE" ]]; then
    echo "Error: $NIX_FILE not found in the current directory."
    exit 1
  fi

  get_latest_version
  update_nix_expression "$LATEST_VERSION"

  echo "Done! You can now rebuild the package."
}

main "$@"
