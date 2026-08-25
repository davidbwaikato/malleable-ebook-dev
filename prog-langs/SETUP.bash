# This file is sourced by ../SETUP.bash.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf 'This script must be sourced, not executed.\n' >&2
  printf 'Use: source %q\n' "${BASH_SOURCE[0]}" >&2
  exit 1
fi

_malleable_ebook_prog_langs_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
_malleable_ebook_dev_root="$(cd -- "$_malleable_ebook_prog_langs_dir/.." >/dev/null 2>&1 && pwd)"

source "$_malleable_ebook_dev_root/versions.env"
source "$_malleable_ebook_dev_root/lib/platform.bash"

_malleable_ebook_host_os="$(malleable_ebook_host_os)" || return 1
_malleable_ebook_host_arch="$(malleable_ebook_host_arch)" || return 1
_malleable_ebook_node_platform="$(malleable_ebook_node_platform "$_malleable_ebook_host_os")" || return 1
_malleable_ebook_node_distribution="node-${MALLEABLE_EBOOK_NODE_VERSION}-${_malleable_ebook_node_platform}-${_malleable_ebook_host_arch}"
MALLEABLE_EBOOK_NODE_HOME="$_malleable_ebook_prog_langs_dir/$_malleable_ebook_node_distribution"
export MALLEABLE_EBOOK_NODE_HOME

if [[ ! -d "$MALLEABLE_EBOOK_NODE_HOME" ]]; then
  printf 'Node.js %s is not installed for %s/%s.\n' \
    "$MALLEABLE_EBOOK_NODE_VERSION" "$_malleable_ebook_host_os" "$_malleable_ebook_host_arch" >&2
  printf 'Run: %q\n' "$_malleable_ebook_prog_langs_dir/GET-NODEJS.sh" >&2
  return 1
fi

_malleable_ebook_node_bin_dir="$(malleable_ebook_node_bin_dir "$_malleable_ebook_host_os" "$MALLEABLE_EBOOK_NODE_HOME")"
case ":$PATH:" in
  *":$_malleable_ebook_node_bin_dir:"*) ;;
  *) export PATH="$_malleable_ebook_node_bin_dir:$PATH" ;;
esac

_malleable_ebook_corepack_home="$_malleable_ebook_prog_langs_dir/corepack"
COREPACK_HOME="$(malleable_ebook_native_path \
  "$_malleable_ebook_host_os" "$_malleable_ebook_corepack_home")"
export COREPACK_HOME

_malleable_ebook_node_executable="$(type -P node 2>/dev/null)" || {
  printf 'Could not locate the project-managed Node.js executable on PATH.\n' >&2
  return 1
}

_malleable_ebook_active_node_version="$("$_malleable_ebook_node_executable" --version 2>/dev/null)" || {
  printf 'Failed to run the project-managed Node.js executable.\n' >&2
  return 1
}

if [[ "$_malleable_ebook_active_node_version" != "$MALLEABLE_EBOOK_NODE_VERSION" ]]; then
  printf 'Expected Node.js %s but activated %s.\n' \
    "$MALLEABLE_EBOOK_NODE_VERSION" "$_malleable_ebook_active_node_version" >&2
  return 1
fi

_malleable_ebook_pnpm_executable="$(type -P pnpm 2>/dev/null)" || {
  printf 'pnpm is not on PATH. Run: %q\n' "$_malleable_ebook_prog_langs_dir/GET-NODEJS.sh" >&2
  return 1
}

_malleable_ebook_active_pnpm_version="$("$_malleable_ebook_pnpm_executable" --version 2>/dev/null)" || {
  printf 'pnpm is not ready. Run: %q\n' "$_malleable_ebook_prog_langs_dir/GET-NODEJS.sh" >&2
  return 1
}

if [[ "$_malleable_ebook_active_pnpm_version" != "$MALLEABLE_EBOOK_PNPM_VERSION" ]]; then
  printf 'Expected pnpm %s but activated %s.\n' \
    "$MALLEABLE_EBOOK_PNPM_VERSION" "$_malleable_ebook_active_pnpm_version" >&2
  return 1
fi

printf 'Activated Node.js %s and pnpm %s from dev/prog-langs.\n' \
  "$_malleable_ebook_active_node_version" "$_malleable_ebook_active_pnpm_version"

unset _malleable_ebook_prog_langs_dir
unset _malleable_ebook_dev_root
unset _malleable_ebook_host_os
unset _malleable_ebook_host_arch
unset _malleable_ebook_node_platform
unset _malleable_ebook_node_distribution
unset _malleable_ebook_node_bin_dir
unset _malleable_ebook_node_executable
unset _malleable_ebook_pnpm_executable
unset _malleable_ebook_corepack_home
unset _malleable_ebook_active_node_version
unset _malleable_ebook_active_pnpm_version
