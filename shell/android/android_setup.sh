#!/usr/bin/env bash

##
# This script holds pre-setup functions
##

##
# android-env-setup.sh — Holistic provisioning of Android NDK, SDK build tools & Zraxyl port
##

set -euo pipefail
IFS=$'\n\t'

### Constants & Defaults #####################################################
readonly SCRIPT_NAME=$(basename "$0")

# Output & install directories (override via env if needed)
readonly ANDROID_DEV_ENV=${ANDROID_DEV_ENV:-"$HOME/android_dev_env"}
readonly ANDROID_OUT=${ANDROID_OUT:-"$ANDROID_DEV_ENV/out"}

# NDK & SDK versions (override via env if needed)
readonly ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION:-"r25b"}
readonly ANDROID_SDK_BUILD_TOOL_VERSION=${ANDROID_SDK_BUILD_TOOL_VERSION:-"31.0.0"}

# Download URLs (override via env if needed)
readonly ANDROID_NDK_LINK=${ANDROID_NDK_LINK:-"https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip"}
readonly ANDROID_SDK_BUILD_TOOL_LINK=${ANDROID_SDK_BUILD_TOOL_LINK:-"https://dl.google.com/android/repository/build-tools_r${ANDROID_SDK_BUILD_TOOL_VERSION}-linux.zip"}

# Zraxyl integration (override ZRAXYL_REPO_URL if needed)
readonly ZRAXYL_REPO_URL=${ZRAXYL_REPO_URL:-"https://github.com/Zraxyl/zraxyl-android.git"}
readonly ZRAXYL_ABI=${ZRAXYL_ABI:-"arm64-v8a"}
readonly ZRAXYL_PLATFORM=${ZRAXYL_PLATFORM:-"android-21"}

# CI‑mode detection (honors $CI or --non-interactive)
CI_MODE=${CI_MODE:-${CI:-false}}

### Utilities #################################################################

# Timestamped, leveled logging
log() {
  local level=$1; shift
  printf '[%s] [%s] %s\n' "$(date +'%Y-%m-%dT%H:%M:%S%z')" "$level" "$*"
}

# Usage/help
usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [--non-interactive] [--help]

Options:
  --non-interactive   Suppress prompts (CI mode).
  --help              Display this message and exit.
EOF
  exit 0
}

# Confirm action (skipped in CI mode)
confirm() {
  local prompt=$1
  if [[ $CI_MODE == true ]]; then
    return 0
  fi
  read -r -p "$prompt [Y/n]: " resp
  [[ -z "$resp" || "$resp" =~ ^[Yy]$ ]]
}

# Cleanup any leftover partial downloads
cleanup() {
  log INFO "Purging partial artifacts"
  find "$ANDROID_OUT" -type f -name '*.partial' -delete || true
}
trap cleanup EXIT

### Core Functions ############################################################

# 1. Prepare directory scaffolding
android_prepare_env() {
  log INFO "Ensuring directory structure under $ANDROID_DEV_ENV"
  mkdir -p "$ANDROID_OUT"/{ndk,build_tools}
}

# 2. Download artifact with idempotence
download_artifact() {
  local url=$1 dest=$2
  if [[ -f $dest ]]; then
    log INFO "Skipping download; artifact exists at $dest"
    return
  fi
  log INFO "Downloading $(basename "$dest")"
  curl --fail --location --progress-bar "$url" --output "${dest}.partial"
  mv "${dest}.partial" "$dest"
}

# 3. Unzip if not already unzipped
unzip_if_needed() {
  local zipfile=$1 target_dir=$2
  if [[ -d $target_dir ]]; then
    log INFO "Skipping unzip; directory exists at $target_dir"
    return
  fi
  log INFO "Unzipping $(basename "$zipfile") → $target_dir"
  unzip -q "$zipfile" -d "$(dirname "$target_dir")"
}

# 4. Clone & build the NeoTerm‑based Zraxyl Android port
android_prepare_zraxyl() {
  local clone_dir="${ANDROID_DEV_ENV}/zraxyl-android"
  local build_dir="${clone_dir}/build"

  log INFO "Provisioning Zraxyl Android port from $ZRAXYL_REPO_URL"

  if [[ -d $clone_dir ]]; then
    log INFO "Updating existing Zraxyl repo"
    git -C "$clone_dir" pull --ff-only
  else
    log INFO "Cloning Zraxyl repository"
    git clone --depth=1 "$ZRAXYL_REPO_URL" "$clone_dir"
  fi

  mkdir -p "$build_dir"
  pushd "$build_dir" >/dev/null

    if [[ -f zraxyl.bin ]]; then
      log INFO "Zraxyl binary present; skipping rebuild"
    else
      log INFO "Configuring Zraxyl build (ABI=$ZRAXYL_ABI, PLATFORM=$ZRAXYL_PLATFORM)"
      cmake .. \
        -DCMAKE_TOOLCHAIN_FILE="${ANDROID_DEV_ENV}/ndk/android-ndk-${ANDROID_NDK_VERSION}/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ZRAXYL_ABI" \
        -DANDROID_PLATFORM="$ZRAXYL_PLATFORM"
      log INFO "Executing Zraxyl compilation"
      cmake --build . -- -j"$(nproc)"
    fi

  popd >/dev/null

  # Export for downstream consumption
  export ZRAXYL_HOME="$clone_dir"
  export PATH="$build_dir:$PATH"
  log INFO "Zraxyl integration complete; ZRAXYL_HOME=$ZRAXYL_HOME"
}

### Main Workflow #############################################################

main() {
  android_prepare_env

  if confirm "Proceed with NDK & SDK build‑tools download?"; then
    download_artifact "$ANDROID_NDK_LINK"   "$ANDROID_OUT/ndk-${ANDROID_NDK_VERSION}.zip"
    download_artifact "$ANDROID_SDK_BUILD_TOOL_LINK" "$ANDROID_OUT/build_tools-${ANDROID_SDK_BUILD_TOOL_VERSION}.zip"
  else
    log WARN "NDK/SDK download skipped..."
  fi

  if confirm "Proceed with unzipping artifacts?"; then
    unzip_if_needed "$ANDROID_OUT/ndk-${ANDROID_NDK_VERSION}.zip"        "${ANDROID_DEV_ENV}/ndk/android-ndk-${ANDROID_NDK_VERSION}"
    unzip_if_needed "$ANDROID_OUT/build_tools-${ANDROID_SDK_BUILD_TOOL_VERSION}.zip" "${ANDROID_DEV_ENV}/build_tools/build-tools-${ANDROID_SDK_BUILD_TOOL_VERSION}"
  else
    log WARN "Unzip step skipped..."
  fi

  if confirm "Install & build the Zraxyl Android port?"; then
    android_prepare_zraxyl
  else
    log WARN "Zraxyl provisioning skipped..."
  fi

  log INFO "All provisioning steps complete. Android + Zraxyl environment is now production‑ready."
}

# Entrypoint
main
