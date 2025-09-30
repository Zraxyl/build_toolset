##
# Functions to make run zraxyl specific things in docker
# * This allows to run this script in other distros ( mainly in github workflows )
##

imgsys_image_manager() {
    # Check for existing image and download if missing
    export IS_MISSING=$(sudo docker image ls -a | grep -wo ${DOCKER_IMAGE_NAME})
    if [ "${IS_MISSING}" = "${DOCKER_IMAGE_NAME}" ]; then
        message "IMGSYS - Image found and not pulling it again"
    else
        sudo docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH}
    fi
    unset IS_MISSING
}

# Run cmd's in docker container
imgsys_run_cmd() {
    sudo docker exec --env PATH=/bin:/sbin:/usr/bin:/usr/sbin --env LD_LIBRARY_PATH=/usr/lib:/usr/lib64 --interactive ${DOCKER_IMGSYS_CONTAINER_NAME} ${@}
}

# Run command in target rootfs
imgsys_target_run() {
    sudo base-chroot ${IMGSYS_WRK}/rootfs ${@}
}

## Make changes to the container that are needed
imgsys_system_setup() {
    imgsys_run_cmd "cp -f /home/developer/$TOOL_MAIN_NAME/build/docker/developing/bottle/${REPO_TYPE}_${DOCKER_IMAGE_ARCH}_bottle.conf /etc/bottle.conf"

    imgsys_run_cmd "bottle -Syyu --needed --noconfirm --disable-download-timeout"

    imgsys_run_cmd "bottle -Syy --needed --noconfirm --disable-download-timeout nano dracut base-install-scripts sudo parted libmd util-linux coreutils"
}

imgsys_container_manager() {
    if [ "$(sudo docker container ls -a | grep -wo ${DOCKER_IMGSYS_CONTAINER_NAME})" = "${DOCKER_IMGSYS_CONTAINER_NAME}" ]; then
        message "IMGSYS - Work container already imported, so lets skip"
    else
        message "IMGSYS - Work container seems to be missing, so lets make it"

        # Create the container
        sudo docker container create \
        --name ${DOCKER_IMGSYS_CONTAINER_NAME} \
        --volume $P_ROOT:$DOCKER_USER_FOLDER/$TOOL_MAIN_NAME \
        --tty \
        --privileged \
        -e LD_LIBRARY_PATH="/lib:/lib64:/usr/lib:/usr/lib64" \
        -e PATH="/bin:/sbin:/usr/bin:/usr/sbin" \
        ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH} \
        /usr/bin/bash
    fi

    # Start the container
    message "IMGSYS - Starting the container"
    sudo docker start ${DOCKER_IMGSYS_CONTAINER_NAME}

    sleep 2
}

imgsys_docker_health_check() {
    # Check if we need to dl the image
    imgsys_image_manager

    # Create work container
    imgsys_container_manager

    # Update/Upgrade current system
    imgsys_system_setup
}

imgsys_docker_cleanup() {
    # Remove imgsys container as we dont need it anymore
    sudo docker container rm -f ${DOCKER_IMGSYS_CONTAINER_NAME}
    message "IMGSYS - Container removed"

    # Here we need to delete main zraxyl image to import new one later on
    sudo docker rmi ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH} -f
    message "IMGSYS - Image removed"
}
