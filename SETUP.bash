# Source this file so its PATH changes remain in the current shell:
#   source ./dev/SETUP.bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf 'This script must be sourced, not executed.\n' >&2
  printf 'Use: source %q\n' "${BASH_SOURCE[0]}" >&2
  exit 1
fi

MALLEABLE_EBOOK_DEV_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
export MALLEABLE_EBOOK_DEV_ROOT

source "$MALLEABLE_EBOOK_DEV_ROOT/prog-langs/SETUP.bash" || return 1
source "$MALLEABLE_EBOOK_DEV_ROOT/cli-tools/SETUP.bash" || return 1
