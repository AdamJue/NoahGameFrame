# NoahGameFrame Build Guide

## Overview

The project now uses:

- `vcpkg` manifest mode for third-party package management
- `CMakePresets.json` for cross-platform configure/build entry points
- `_Out/Debug` and `_Out/Release` as runtime output directories

Legacy scripts such as `Dependencies/build_dep.bat`, `Dependencies/build_dep.sh`, `Dependencies/build_dep_with_source_code.bat`, `Dependencies/build_vcpkg.sh`, `install4cmake.sh`, and `buildServer.sh` are no longer the recommended default path for day-to-day development builds.

Those legacy entry points are retained as compatibility wrappers only: they now emit a deprecation message and forward into the preset-based configure/build flow.

## Prerequisites

Before configuring the project, make sure you have:

- Git
- CMake `>= 3.21`
- A C++17 compiler
- `vcpkg`

Also initialize vendor dependencies stored as submodules:

```bash
git submodule update --init --recursive
```

## vcpkg setup

This repository uses `vcpkg.json` in manifest mode. CMake will automatically install required dependencies when the toolchain is active.

Recommended environment variable:

```powershell
$env:VCPKG_ROOT="D:/tools/vcpkg"
```

If `VCPKG_ROOT` is not set, pass the toolchain file manually:

```bash
cmake --preset windows-msvc-debug -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake
```

## Configure

Available presets are defined in `CMakePresets.json`.

### Windows

```bash
cmake --preset windows-msvc-debug
cmake --preset windows-msvc-release
```

### Linux

```bash
cmake --preset linux-debug
cmake --preset linux-release
```

### macOS

```bash
cmake --preset macos-debug
cmake --preset macos-release
```

## Build

Run the matching build preset after configure:

```bash
cmake --build --preset windows-msvc-debug
```

Examples:

```bash
cmake --build --preset windows-msvc-release
cmake --build --preset linux-debug
cmake --build --preset macos-debug
```

## Output layout

- `build-vcpkg/<preset>/`: CMake cache, generated project files, generated protobuf code
- `_Out/Debug`: debug binaries and runtime data
- `_Out/Release`: release binaries and runtime data

The protobuf generated headers are emitted into the build tree and added to the include path ahead of checked-in paths, so generated headers stay consistent with the selected `protobuf` version.

## Optional CMake switches

The root CMake exposes optional feature switches. For example:

```bash
cmake --preset windows-msvc-debug -DNF_BUILD_RENDER=OFF -DNF_BUILD_BLUEPRINT=OFF
```

## Troubleshooting

### Generator mismatch

If you previously configured the repository with another generator, remove the old build directory and configure again:

```bash
cmake --fresh --preset windows-msvc-debug
```

or delete the stale directory under `build-vcpkg/`.

### Missing dependencies

Make sure:

- `vcpkg` is installed
- `VCPKG_ROOT` points to the correct location, or `CMAKE_TOOLCHAIN_FILE` is set
- submodules are initialized

### Windows/MSVC warnings about `/static-libstdc++`

The project CMake files have been cleaned to avoid GNU-only `-static-libstdc++` linker flags on MSVC. If this warning reappears, search for new custom `target_link_libraries(... -static-libstdc++)` additions in newly added modules.
