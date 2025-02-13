##
# Exports for Android Port
##

# Zraxyl specific
ANDROID_SYSTEM=/data/data/hilled.pwnterm/files/

# Misc links and paths for toolset
export ANDROID_OUT=${P_ROOT}/out/android
export ANDROID_DEV_ENV=${P_ROOT}/android
export ANDROID_SDK=${ANDROID_DEV_ENV}/sdk
export ANDROID_NDK=${ANDROID_DEV_ENV}/ndk
export ANDROID_BUILD_TOOL=${ANDROID_DEV_ENV}/build_tools
export ANDROID_REPO=https://dl.google.com/android/repository

# NDK
export ANDROID_NDK_VERSION=25c
export ANDROID_NDK_FILE="android-ndk-r${ANDROID_NDK_VERSION}-linux.zip"
export ANDROID_NDK_PATH=$ANDROID_HOME/ndk/${ANDROID_NDK_VERSION}
export ANDROID_NDK_LINK="${ANDROID_REPO}/${ANDROID_NDK_FILE}"

# SDK
export ANDROID_VERSION=13
export ANDROID_SDK_BUILD_TOOL_VERSION=33.0.2
export ANDROID_SDK_BUILD_TOOL_FILE="build-tools_r${ANDROID_SDK_BUILD_TOOL_VERSION}-linux.zip"
export ANDROID_SDK_BUILD_TOOL_LINK="${ANDROID_REPO}/${ANDROID_SDK_BUILD_TOOL_FILE}"

# Platform tools ( Just in case but hopefully not needed )
export ANDROID_SDK_PLATFORM_VERSION=9123335
export ANDROID_SDK_PLATFORM_FILE=""
export ANDROID_SDK_PLATFORM_LINK=

# Target API
export ANDROID_TARGET_API=30
