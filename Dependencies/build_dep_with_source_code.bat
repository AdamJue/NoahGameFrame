@echo off
setlocal
set "NF_REPO_ROOT=%~dp0.."
set "NF_PRESET=%~1"

if "%NF_PRESET%"=="" (
    set "NF_PRESET=windows-msvc-debug"
)

echo [DEPRECATED] Dependencies\build_dep_with_source_code.bat is deprecated.
echo [DEPRECATED] Please use CMakePresets directly for configure/build.
echo [DEPRECATED] Forwarding to: cmake --preset %NF_PRESET%

where cmake >nul 2>nul
if errorlevel 1 (
    echo [ERROR] cmake was not found in PATH.
    echo [HINT] Install CMake 3.21+ and try again.
    exit /b 1
)

pushd "%NF_REPO_ROOT%"
git submodule update --init --recursive
if errorlevel 1 (
    popd
    exit /b 1
)

cmake --preset "%NF_PRESET%"
set "NF_EXIT=%ERRORLEVEL%"
popd
exit /b %NF_EXIT%