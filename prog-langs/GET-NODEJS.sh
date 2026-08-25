#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DEV_ROOT="$(cd -- "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"

source "$DEV_ROOT/versions.env"
source "$DEV_ROOT/lib/platform.bash"

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

download_file() {
  local source_url="$1"
  local destination="$2"
  local partial_file="${destination}.part"

  rm -f -- "$partial_file"

  if command -v curl >/dev/null 2>&1; then
    curl --fail --location --retry 3 --silent --show-error \
      --output "$partial_file" "$source_url"
  elif command -v wget >/dev/null 2>&1; then
    wget --output-document="$partial_file" "$source_url"
  else
    fail "curl or wget is required to download Node.js."
  fi

  mv -- "$partial_file" "$destination"
}

sha256_of() {
  local source_file="$1"

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$source_file" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$source_file" | awk '{print $1}'
  elif command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$source_file" | awk '{print $NF}'
  else
    fail "sha256sum, shasum, or openssl is required to verify Node.js."
  fi
}

verify_archive() {
  local archive_path="$1"
  local archive_name="$2"
  local checksums_path="$3"
  local expected_checksum
  local actual_checksum

  expected_checksum="$(awk -v archive="$archive_name" '$2 == archive { print $1; exit }' "$checksums_path")"
  [[ -n "$expected_checksum" ]] || fail "No official checksum was found for $archive_name."

  actual_checksum="$(sha256_of "$archive_path")"
  if [[ "$actual_checksum" != "$expected_checksum" ]]; then
    printf 'Checksum mismatch for %s.\n' "$archive_path" >&2
    printf 'Expected: %s\n' "$expected_checksum" >&2
    printf 'Actual:   %s\n' "$actual_checksum" >&2
    return 1
  fi
}

extract_archive() {
  local host_os="$1"
  local archive_path="$2"
  local destination="$3"

  if [[ "$host_os" == "windows" ]]; then
    if command -v unzip >/dev/null 2>&1; then
      unzip -q "$archive_path" -d "$destination"
    elif command -v tar >/dev/null 2>&1; then
      tar -xf "$archive_path" -C "$destination"
    else
      fail "unzip or a zip-capable tar command is required to unpack Node.js."
    fi
  else
    tar --no-same-owner -xzf "$archive_path" -C "$destination"
  fi
}

move_extracted_distribution() {
  local host_os="$1"
  local source_dir="$2"
  local destination_dir="$3"
  local delay

  if [[ "$host_os" != "windows" ]]; then
    mv -- "$source_dir" "$destination_dir"
    return
  fi

  # Windows security and compatibility scanners can briefly retain handles to
  # newly extracted executables, causing an otherwise valid directory rename
  # to fail with "Permission denied". Retry for a short, bounded period rather
  # than using sync, which flushes writes but does not release file handles.
  if mv -- "$source_dir" "$destination_dir" 2>/dev/null; then
    return
  fi

  for delay in 0.25 0.5 1 2 4; do
    printf 'Windows has temporarily locked the extracted Node.js directory; retrying in %s seconds...\n' \
      "$delay"
    sleep "$delay"

    if mv -- "$source_dir" "$destination_dir" 2>/dev/null; then
      return
    fi
  done

  printf 'Unable to install Node.js after waiting for Windows to release the extracted files.\n' >&2
  mv -- "$source_dir" "$destination_dir"
}

host_os="$(malleable_ebook_host_os)"
host_arch="$(malleable_ebook_host_arch)"
node_platform="$(malleable_ebook_node_platform "$host_os")"
archive_extension="$(malleable_ebook_node_archive_extension "$host_os")"
node_distribution="node-${MALLEABLE_EBOOK_NODE_VERSION}-${node_platform}-${host_arch}"
archive_name="${node_distribution}.${archive_extension}"
install_dir="$SCRIPT_DIR/$node_distribution"
download_dir="$SCRIPT_DIR/downloads"
archive_path="$download_dir/$archive_name"
checksums_path="$download_dir/SHASUMS256-${MALLEABLE_EBOOK_NODE_VERSION}.txt"
base_url="https://nodejs.org/dist/${MALLEABLE_EBOOK_NODE_VERSION}"

mkdir -p -- "$download_dir"

if [[ ! -f "$checksums_path" ]]; then
  printf 'Downloading official Node.js checksums...\n'
  download_file "$base_url/SHASUMS256.txt" "$checksums_path"
fi

if [[ ! -f "$archive_path" ]]; then
  printf 'Downloading %s...\n' "$archive_name"
  download_file "$base_url/$archive_name" "$archive_path"
else
  printf 'Using cached download: %s\n' "$archive_path"
fi

if ! verify_archive "$archive_path" "$archive_name" "$checksums_path"; then
  fail "Remove the invalid cached archive and run this script again."
fi
printf 'Verified SHA-256 checksum for %s.\n' "$archive_name"

if [[ ! -d "$install_dir" ]]; then
  extract_dir="$(mktemp -d "$SCRIPT_DIR/.node-extract.XXXXXX")"
  cleanup_extract_dir() {
    rm -rf -- "$extract_dir"
  }
  trap cleanup_extract_dir EXIT

  printf 'Installing Node.js under %s...\n' "$SCRIPT_DIR"
  extract_archive "$host_os" "$archive_path" "$extract_dir"
  extracted_distribution="$extract_dir/$node_distribution"
  [[ -d "$extracted_distribution" ]] || fail "The Node.js archive had an unexpected directory layout."
  move_extracted_distribution "$host_os" "$extracted_distribution" "$install_dir"

  cleanup_extract_dir
  trap - EXIT
else
  printf 'Node.js is already installed: %s\n' "$install_dir"
fi

node_bin_dir="$(malleable_ebook_node_bin_dir "$host_os" "$install_dir")"
node_executable="$node_bin_dir/node"
[[ "$host_os" == "windows" ]] && node_executable="$node_bin_dir/node.exe"
[[ -x "$node_executable" ]] || fail "Node.js executable not found: $node_executable"

installed_node_version="$($node_executable --version)"
[[ "$installed_node_version" == "$MALLEABLE_EBOOK_NODE_VERSION" ]] || \
  fail "Expected Node.js $MALLEABLE_EBOOK_NODE_VERSION but found $installed_node_version."

export PATH="$node_bin_dir:$PATH"
corepack_home="$SCRIPT_DIR/corepack"
mkdir -p -- "$corepack_home"
COREPACK_HOME="$(malleable_ebook_native_path "$host_os" "$corepack_home")"
export COREPACK_HOME

if ! command -v corepack >/dev/null 2>&1; then
  fail "This Node.js distribution does not include Corepack."
fi

printf 'Activating pnpm %s through Corepack...\n' "$MALLEABLE_EBOOK_PNPM_VERSION"
corepack enable --install-directory "$node_bin_dir"
corepack install --global "pnpm@${MALLEABLE_EBOOK_PNPM_VERSION}"

installed_pnpm_version="$(pnpm --version)"
[[ "$installed_pnpm_version" == "$MALLEABLE_EBOOK_PNPM_VERSION" ]] || \
  fail "Expected pnpm $MALLEABLE_EBOOK_PNPM_VERSION but found $installed_pnpm_version."

printf 'Installed Node.js %s and pnpm %s for %s/%s.\n' \
  "$installed_node_version" "$installed_pnpm_version" "$host_os" "$host_arch"
