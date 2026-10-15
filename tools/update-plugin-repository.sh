#!/bin/sh

# Add a built OPNfluent package to an existing custom pkg repository and
# regenerate its catalogue. Signing remains controlled by the repository's
# existing pkg configuration/build process.

set -eu

if [ "$#" -ne 2 ]; then
    echo "usage: $0 /path/to/os-theme-opnfluent.pkg /path/to/repository" >&2
    exit 64
fi

PACKAGE=$1
REPOSITORY=$2

if [ "$(uname -s)" != "FreeBSD" ]; then
    echo "error: repository generation must run on FreeBSD" >&2
    exit 1
fi

if [ ! -f "${PACKAGE}" ]; then
    echo "error: package not found: ${PACKAGE}" >&2
    exit 1
fi

if [ ! -d "${REPOSITORY}" ]; then
    echo "error: repository directory not found: ${REPOSITORY}" >&2
    exit 1
fi

case $(basename -- "${PACKAGE}") in
    os-theme-opnfluent-*.pkg) ;;
    *)
        echo "error: not an OPNfluent plugin package: ${PACKAGE}" >&2
        exit 1
        ;;
esac

install -m 0644 "${PACKAGE}" "${REPOSITORY}/$(basename -- "${PACKAGE}")"
pkg repo "${REPOSITORY}"

echo "repository catalogue updated: ${REPOSITORY}"
