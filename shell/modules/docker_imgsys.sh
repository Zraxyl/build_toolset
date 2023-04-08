docker_imgsys_amd64() {
    # cd to imgsys dir
    cd "${P_ROOT}/build/docker/imgsys"

    # Execute build only image
    ./build.sh --amd64-image
}

docker_imgsys_arm64() {
    # cd to imgsys dir
    cd "${P_ROOT}/build/docker/imgsys"

    # Execute build only image
    ./build.sh --arm64-image
}
