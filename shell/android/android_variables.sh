##
# android_variables.sh — Environment exports for Android tooling & Zraxyl port
##

# ─── Project Root ─────────────────────────────────────────────────────────────
# Must be set by CI or user before sourcing this file:
#   export P_ROOT="/path/to/your/project"
# e.g. in CI pipeline, or in your ~/.bashrc.

# ─── Android System Path ──────────────────────────────────────────────────────
export ANDROID_SYSTEM="/data/data/hilled.pwnterm/files/"

# ─── Output & Dev‑Env Directories ─────────────────────────────────────────────
export ANDROID_OUT="${P_ROOT}/out/android"
export ANDROID_DEV_ENV="${P_ROOT}/android"
export ANDROID_SDK="${ANDROID_DEV_ENV}/sdk"
export ANDROID_NDK="${ANDROID_DEV_ENV}/ndk"
export ANDROID_BUILD_TOOL="${ANDROID_DEV_ENV}/build_tools"

# ─── Repository Base URL ──────────────────────────────────────────────────────
export ANDROID_REPO="https://dl.google.com/android/repository"

# ─── NDK Configuration ────────────────────────────────────────────────────────
export ANDROID_NDK_VERSION="25c"
export ANDROID_NDK_FILE="android-ndk-r${ANDROID_NDK_VERSION}-linux.zip"
export ANDROID_NDK_PATH="${ANDROID_NDK}/${ANDROID_NDK_VERSION}"
export ANDROID_NDK_LINK="${ANDROID_REPO}/${ANDROID_NDK_FILE}"

# ─── SDK Build‑Tools Configuration ────────────────────────────────────────────
export ANDROID_SDK_BUILD_TOOL_VERSION="33.0.2"
export ANDROID_SDK_BUILD_TOOL_FILE="build-tools_r${ANDROID_SDK_BUILD_TOOL_VERSION}-linux.zip"
export ANDROID_SDK_BUILD_TOOL_LINK="${ANDROID_REPO}/${ANDROID_SDK_BUILD_TOOL_FILE}"

# ─── (Optional) Platform Tools ────────────────────────────────────────────────
export ANDROID_SDK_PLATFORM_VERSION="9123335"
export ANDROID_SDK_PLATFORM_FILE=""
export ANDROID_SDK_PLATFORM_LINK=""

# ─── Target API Level ─────────────────────────────────────────────────────────
export ANDROID_TARGET_API="30"

# ─── Zraxyl Port Configuration ────────────────────────────────────────────────
export ZRAXYL_REPO_URL="https://github.com/YourOrg/zraxyl-android.git"
export ZRAXYL_ABI="arm64-v8a"
export ZRAXYL_PLATFORM="android-21"
