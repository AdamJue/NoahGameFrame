#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
preset="${1:-}"

if [[ -z "${preset}" ]]; then
    case "$(uname -s)" in
        Darwin)
            preset="macos-debug"
            ;;
        Linux)
            preset="linux-debug"
            ;;
        *)
            echo "[ERROR] Unsupported platform: $(uname -s)"
            exit 1
            ;;
    esac
fi

echo "[DEPRECATED] Dependencies/build_dep.sh is deprecated."
echo "[DEPRECATED] Please use CMakePresets directly for configure/build."
echo "[DEPRECATED] Forwarding to: cmake --preset ${preset}"

if ! command -v cmake >/dev/null 2>&1; then
    echo "[ERROR] cmake was not found in PATH."
    echo "[HINT] Install CMake 3.21+ and try again."
    exit 1
fi

cd "${repo_root}"
git submodule update --init --recursive
cmake --preset "${preset}"
