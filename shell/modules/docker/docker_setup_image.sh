docker_start_service() {
    # Start dockerd with systemctl
    sudo systemctl restart docker
}

docker_image_check() {
    docker_start_service

    # Check weather we need to pull image and do the magic or not
    if [ -f $TOOL_CHECKS/docker_ready ]; then
        msg_debug "Toolset has image status as active, doing proper image check"
        message "Doing image quality check"

        # Check for existing image download
        if [ $(sudo docker image ls -a | grep -o hilledkinged/evolinx) = "hilledkinged/evolinx" ]; then
            message "Image already pulled, skipping..."
        fi
    else
        message "Toolset check list has missing check, checking image and container status"

        if [ "$(sudo docker image ls -a | grep -o hilledkinged/evolinx)" = "hilledkinged/evolinx" ]; then
            message "Image already pulled, skipping..."
        else
            message "Pulling evolinx image as none was found"
            if [ "${P_ARCH}" = "aarch64" ]; then
                sudo docker pull ${DOCKER_IMAGE_NAME}:aarch64
            else
                sudo docker pull ${DOCKER_IMAGE_NAME}:latest
            fi
        fi
    fi
}
