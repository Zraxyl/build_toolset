##
# Functions like: build fresh image and push newly made image
##

imgsys_make_env () {
    # When making chroot env then the parent folder needs to be owned by root
    # Otherwise stuff like systemd will start having issues
    sudo mkdir -p ${IMGSYS_WRK}/rootfs
}

imgsys_cleanup_env() {
    message "IMGSYS - Cleaning up environment"
    as_root_del ${IMGSYS_WRK}/rootfs
}

imgsys_strap_base() {
    # Strap fresh rootfs
    imgsys_run_cmd "base-strap /home/developer/$TOOL_MAIN_NAME/out/imgsys/rootfs base-chroot"

    # Some misc changes
    imgsys_target_run "ldconfig"
    imgsys_target_run "rm -rf /var/lib/${PACKAGE_MANAGER}/sync/*"
}

imgsys_rootfs_to_image() {
    cd ${IMGSYS_WRK} && sudo tar -C rootfs -c . | sudo docker import - ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH}
}

imgsys_test() {
    if [ ! -f ${IMGSYS_WRK}/rootfs/usr/bin/bash ]; then
        msg_error "IMGSYS - Rootfs installation hard failed"
    else
        message "IMGSYS - Rootfs is installed"
    fi
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
    message "IMGSYS - Preparing env"
    imgsys_make_env

    # strap new rootfs
    message "IMGSYS - Strapping new rootfs base"
    imgsys_strap_base

    # Remove previously pulled image
    message "IMGSYS - Preparing to remove old image and container"
    imgsys_docker_cleanup

    # Import tarball to image
    message "IMGSYS - Importing final rootfs as image"
    imgsys_rootfs_to_image

    # Test fresly made image before push
    message "IMGSYS - Testing newly made image"
    imgsys_test

    message "IMGSYS - Finished"
}

imgsys_build() {
    message "IMGSYS - Building image for ${ARCH}"
    imgsys_build_base

    # This requires user to be signed into docker beforehand
    if [ -f $TOOL_TEMP/imgsys_push ]; then
        if [ $(cat $TOOL_TEMP/imgsys_push) = "true" ]; then
            imgsys_push
        fi
    fi
}
