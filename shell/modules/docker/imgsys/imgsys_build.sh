##
# Functions like: build fresh image and push newly made image
##

imgsys_make_env () {
    # When making chroot env then the parent folder needs to be owned by root
    # Otherwise stuff like systemd will start having issues
    sudo mkdir -p ${IMGSYS_WRK}/rootfs
}

imgsys_cleanup_env() {
    message "Cleaning up environment"
    as_root_del ${IMGSYS_WRK}/rootfs
}

imgsys_strap_base() {
    imgsys_run_cmd "base-strap /home/developer/$TOOL_MAIN_NAME/out/imgsys/rootfs base-chroot"
}

imgsys_rootfs_to_image() {
    cd ${IMGSYS_WRK} && sudo tar -C rootfs -c . | sudo docker import - ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH}
}

imgsys_push() {
    sudo docker image push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH}
}

imgsys_build_base() {
    # Check the imgsys worker container and base image status ( basically prepare the docker for the job )
    imgsys_docker_health_check

    if [ -d ${IMGSYS_WRK}/rootfs ]; then
        imgsys_cleanup_env
    fi

    # Prepare env in tmp
    message "Preparing env"
    imgsys_make_env

    # strap new rootfs
    message "Strapping new rootfs base"
    imgsys_strap_base

    # Remove previously pulled image
    message "Preparing to remove old image and container"
    imgsys_docker_cleanup

    # import tarball to image
    message "Importing final rootfs as image"
    imgsys_rootfs_to_image
}

imgsys_build() {
    message "Building image for ${ARCH}"
    imgsys_build_base

    # This requires user to be signed into docker beforehand
    if [ -f $TOOL_TEMP/imgsys_push ]; then
        if [ $(cat $TOOL_TEMP/imgsys_push) = "true" ]; then
            imgsys_push
        fi
    fi
}
