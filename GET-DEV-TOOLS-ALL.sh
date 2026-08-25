#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

"$SCRIPT_DIR/prog-langs/GET-NODEJS.sh"

printf '\nDevelopment tools are installed. Activate them in this shell with:\n'
printf '  source %q\n' "$SCRIPT_DIR/SETUP.bash"
