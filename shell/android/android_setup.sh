##
# This script holds pre-setup functions
##

android_prepare_env() {
    message "Preparing initial development structure"

    mkdir -p ${ANDROID_DEV_ENV}/{ndk,build_tools}
    mkdir -p ${ANDROID_OUT}
}

android_prepare_essentials() {
    message "Downloading NDK"
    wget ${ANDROID_NDK_LINK} -O ${ANDROID_OUT}/ndk-$ANDROID_NDK_VERSION.zip.partial_download
    mv ${ANDROID_OUT}/ndk-$ANDROID_NDK_VERSION.zip.partial_download ${ANDROID_OUT}/ndk-$ANDROID_NDK_VERSION.zip

    message "Downloading SDK"
    wget ${ANDROID_SDK_BUILD_TOOL_LINK} -O ${ANDROID_OUT}/build_tools-$ANDROID_SDK_BUILD_TOOL_VERSION.zip.partial_download
    mv ${ANDROID_OUT}/build_tools-$ANDROID_SDK_BUILD_TOOL_VERSION.zip.partial_download ${ANDROID_OUT}/build_tools-$ANDROID_SDK_BUILD_TOOL_VERSION.zip

    ndk_zip="${ANDROID_OUT}/ndk-$ANDROID_NDK_VERSION.zip"
    bldt_zip="${ANDROID_OUT}/build_tools-$ANDROID_SDK_BUILD_TOOL_VERSION.zip"

    message "Unzipping NDK"
    unzip -q $ndk_zip -d ${ANDROID_NDK}

    message "Unzipping Build Tools"
    unzip -q $bldt_zip -d ${ANDROID_BUILD_TOOL}
}

android_health_check() {

}
