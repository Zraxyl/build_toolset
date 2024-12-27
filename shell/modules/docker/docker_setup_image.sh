docker_start_service() {
    # Start dockerd with systemctl
    sudo systemctl restart docker
}

docker_image_check() {
    docker_start_service

    # Check for existing image download
    if [[ "$(sudo docker image ls -a | grep -o ${DOCKER_IMAGE_NAME})" = "${DOCKER_IMAGE_NAME}" ]]; then
        message "Image already pulled, skipping..."
    else
        message "Pulling docker image as none was found"
        if [ "${P_ARCH}" = "aarch64" ]; then
            msg_error "ARM64 docker image dosent exist yet"
            sudo docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH}
        else
            sudo docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH}
        fi
    fi
}
