##
# Just to allow iso creation in foreign distros
##

# Create iso builder container
docker_iso_setup_env() {
    # Simple check for base image
    docker_image_check

    # Create iso creator container
    docker_create_container ${ISO_CONTAINER_NAME} ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH}

    # Start container
    docker_start_container ${ISO_CONTAINER_NAME}
    docker_container_sysedit ${ISO_CONTAINER_NAME}
}

# Basic health check
docker_iso_checkup() {
    export CHECKIT1=$(sudo docker container ls -a | grep -wo ${ISO_CONTAINER_NAME})

    if [ -z ${CHECKIT1} ]; then
        CHECKIT="empty"
    fi

    if [ ! "${CHECKIT1}" = "${ISO_CONTAINER_NAME}" ]; then
        docker_iso_setup_env
    else
        docker_start_container ${ISO_CONTAINER_NAME}
        docker_iso_update
    fi
}

docker_iso_update() {
    # Install required packages for iso creation
    docker_run_cmd ${ISO_CONTAINER_NAME} "bottle --noconfirm --disable-download-timeout -Syyu bash libisofs libisoburn base-install-scripts"
}

docker_iso_build() {
    docker_user_run_cmd ${ISO_CONTAINER_NAME} "cd ~/ZRAXYL && ./envsetup --mkiso"
}
