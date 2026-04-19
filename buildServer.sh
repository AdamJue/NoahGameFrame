#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")" && pwd)"
mode="$(printf '%s' "${1:-RELEASE}" | tr '[:lower:]' '[:upper:]')"

case "$(uname -s)" in
    Darwin)
        platform="macos"
        ;;
    Linux)
        platform="linux"
        ;;
    *)
        echo "[ERROR] Unsupported platform: $(uname -s)"
        exit 1
        ;;
esac

case "${mode}" in
    DEBUG)
        preset="${platform}-debug"
        ;;
    RELEASE|"")
        preset="${platform}-release"
        ;;
    *)
        preset="${1}"
        ;;
esac

echo "[DEPRECATED] buildServer.sh is deprecated."
echo "[DEPRECATED] Please use CMakePresets directly for configure/build."
echo "[DEPRECATED] Forwarding to:"
echo "[DEPRECATED]   cmake --preset ${preset}"
echo "[DEPRECATED]   cmake --build --preset ${preset}"

if ! command -v cmake >/dev/null 2>&1; then
    echo "[ERROR] cmake was not found in PATH."
    echo "[HINT] Install CMake 3.21+ and try again."
    exit 1
fi

cd "${repo_root}"
git submodule update --init --recursive
cmake --preset "${preset}"
cmake --build --preset "${preset}"
