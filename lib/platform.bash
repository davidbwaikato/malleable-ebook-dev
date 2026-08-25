# Shared host-detection helpers. This file is sourced by the setup and download
# scripts; it is not intended to be run directly.

malleable_ebook_host_os() {
  local kernel_name
  kernel_name="${MALLEABLE_EBOOK_TEST_UNAME_S:-$(uname -s)}"

  case "$kernel_name" in
    MINGW*|MSYS*|CYGWIN*) printf '%s\n' "windows" ;;
    Linux*)                printf '%s\n' "linux" ;;
    Darwin*)               printf '%s\n' "macos" ;;
    *)
      printf 'Unsupported operating system reported by uname: %s\n' "$kernel_name" >&2
      return 1
      ;;
  esac
}

malleable_ebook_host_arch() {
  local machine_name
  machine_name="${MALLEABLE_EBOOK_TEST_UNAME_M:-$(uname -m)}"

  case "$machine_name" in
    x86_64|amd64)  printf '%s\n' "x64" ;;
    arm64|aarch64) printf '%s\n' "arm64" ;;
    *)
      printf 'Unsupported processor architecture reported by uname: %s\n' "$machine_name" >&2
      return 1
      ;;
  esac
}

malleable_ebook_node_platform() {
  case "$1" in
    windows) printf '%s\n' "win" ;;
    linux)   printf '%s\n' "linux" ;;
    macos)   printf '%s\n' "darwin" ;;
    *)
      printf 'Unsupported normalized operating system: %s\n' "$1" >&2
      return 1
      ;;
  esac
}

malleable_ebook_node_archive_extension() {
  case "$1" in
    windows) printf '%s\n' "zip" ;;
    linux|macos) printf '%s\n' "tar.gz" ;;
    *)
      printf 'Unsupported normalized operating system: %s\n' "$1" >&2
      return 1
      ;;
  esac
}

malleable_ebook_node_bin_dir() {
  local host_os="$1"
  local install_dir="$2"

  if [[ "$host_os" == "windows" ]]; then
    printf '%s\n' "$install_dir"
  else
    printf '%s\n' "$install_dir/bin"
  fi
}

malleable_ebook_native_path() {
  local host_os="$1"
  local source_path="$2"

  if [[ "$host_os" == "windows" ]] && command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$source_path"
  else
    printf '%s\n' "$source_path"
  fi
}
