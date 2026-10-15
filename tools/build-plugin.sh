#!/bin/sh

# Build os-theme-opnfluent with the official OPNsense plugin framework.
# Run this script on OPNsense/FreeBSD after placing this repository at
# misc/theme-opnfluent inside an OPNsense plugins checkout.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PLUGIN_DIR=$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)
FRAMEWORK="${PLUGIN_DIR}/../../Mk/plugins.mk"

if [ "$(uname -s)" != "FreeBSD" ]; then
    echo "error: package builds must run on OPNsense/FreeBSD" >&2
    exit 1
fi

if [ ! -f "${FRAMEWORK}" ]; then
    echo "error: OPNsense plugin framework not found at ${FRAMEWORK}" >&2
    echo "place the project at misc/theme-opnfluent in an opnsense/plugins checkout" >&2
    exit 1
fi

if ! command -v pkg >/dev/null 2>&1; then
    echo "error: FreeBSD pkg utility not found" >&2
    exit 1
fi

make -C "${PLUGIN_DIR}" package

PACKAGE=$(find "${PLUGIN_DIR}/work/pkg" -maxdepth 1 -type f -name 'os-theme-opnfluent-*.pkg' | sort | tail -n 1)
if [ -z "${PACKAGE}" ]; then
    echo "error: package build completed without an os-theme-opnfluent package" >&2
    exit 1
fi

echo "package: ${PACKAGE}"
