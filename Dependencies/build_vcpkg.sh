#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
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

echo "[DEPRECATED] Dependencies/build_vcpkg.sh is deprecated."
echo "[DEPRECATED] Please use CMakePresets directly for configure/build."
echo "[DEPRECATED] Forwarding to: cmake --preset ${preset}"

exec "${script_dir}/build_dep.sh" "${preset}"