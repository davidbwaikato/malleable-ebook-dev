# This file is sourced by ../SETUP.bash. No project-managed CLI tools are
# currently required.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf 'This script must be sourced, not executed.\n' >&2
  printf 'Use: source %q\n' "${BASH_SOURCE[0]}" >&2
  exit 1
fi
