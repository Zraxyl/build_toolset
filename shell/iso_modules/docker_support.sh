##
# Just to allow iso creation in foreign distros
##

# Create iso builder container
docker_iso_setup_env() {
    # Simple check for base image
    docker_image_check

    # Safety check
    set +e
    docker_remove_container ${ISO_CONTAINER_NAME} &> /dev/null
    set -e

    # Create iso creator container
    docker_create_container ${ISO_CONTAINER_NAME} ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH}

    # Start container
    docker_start_container ${ISO_CONTAINER_NAME}
    docker_container_sysedit ${ISO_CONTAINER_NAME}
}

docker_iso_update() {
    # Install required packages for iso creation
    docker_run_cmd ${ISO_CONTAINER_NAME} "bottle --needed --noconfirm --disable-download-timeout -Syyu bash libisofs libisoburn base-install-scripts linux-firmware sudo dracut"
}

# Basic health check
docker_iso_checkup() {
    docker_iso_setup_env
    docker_iso_update
}

docker_iso_build() {
    # Now that we are ready then launch toolset in docker container for iso creation
    docker_user_run_cmd ${ISO_CONTAINER_NAME} 'cd ~/ZRAXYL && ./envsetup --mkiso-clean-cli'
}
