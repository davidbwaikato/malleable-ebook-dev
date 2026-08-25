# Malleable eBook Reader development tools

This repository contains reproducible, project-local programming-language and
command-line tool setup for
[`malleable-ebook-reader`](https://github.com/davidbwaikato/malleable-ebook-reader).
It is checked out as that repository's `dev/` submodule.

Downloaded archives, extracted runtimes, and package-manager caches are ignored
by Git. The scripts do not require administrator access and do not replace a
machine's system-wide Node.js installation.

## Quick start

From the parent Malleable eBook Reader repository in Bash or Git Bash:

```bash
./dev/GET-DEV-TOOLS-ALL.sh
source ./dev/SETUP.bash

node --version
pnpm --version
pnpm install --frozen-lockfile
pnpm dev
```

`SETUP.bash` must be sourced so its environment changes remain in the current
terminal. Source it once in each new terminal used for the project.

## Supported hosts

The single Node.js installer supports official 64-bit Node.js builds for:

| Host | Architectures | Archive |
| --- | --- | --- |
| Windows through Git Bash | x64, ARM64 | `.zip` |
| Linux | x64, ARM64 | `.tar.gz` |
| macOS | Intel x64, Apple Silicon ARM64 | `.tar.gz` |

The script detects the host with `uname`, downloads from `nodejs.org`, and
verifies the archive against Node.js's published `SHASUMS256.txt` before
extracting it. It uses `curl` when available and falls back to `wget`.

## Layout

```text
cli-tools/                  Future project-local CLI tools
lib/                        Shared host-detection functions
prog-langs/                 Node.js download and activation scripts
GET-DEV-TOOLS-ALL.sh        Install every required development tool
SETUP.bash                  Activate installed tools in the current shell
versions.env                Pinned Node.js and pnpm versions
```

At present, Node.js and pnpm are the only managed tools. pnpm is provisioned
through the Corepack bundled with Node.js 24; its Corepack cache also remains
inside the ignored `prog-langs/` area.

## Updating versions

Change the pins in `versions.env`, then keep the parent repository aligned:

- `.nvmrc` should contain the Node.js version without the leading `v`;
- `package.json` should declare the matching Node.js engine; and
- `package.json#packageManager` should name the matching pnpm version.

Run `GET-DEV-TOOLS-ALL.sh` again. Because installations use the complete Node.js
version, a newly pinned runtime can coexist with an older ignored installation.
