##
# This module contains static functions for other docker modules
##

docker_export() {
    docker_stop_container $DOCKER_BASE_CONTAINER_NAME

    mkdir -p $TOOL_TEMP/docker_container

    message "Exporting docker container $1 for $2"
    as_root_del "$TOOL_TEMP/docker_container/$2.tar"

    sleep 2

    sudo docker export "$1" > "$TOOL_TEMP/docker_container/$2.tar"
}

# Here we will take care of the docker retarted way to
# import file as image -> make container of image -> delete the image
# Like why... ( let me just import container file as container and not the image )
docker_import() {
    message "Importing container as image: $DOCKER_IMAGE_NAME_TEMP"
    cat "$TOOL_TEMP/docker_container/$1.tar" | sudo docker import - $DOCKER_IMAGE_NAME_TEMP

    docker_create_container $1 $DOCKER_IMAGE_NAME_TEMP

    message "Removing temporary image"
    docker_remove_image $DOCKER_IMAGE_NAME_TEMP

    message "Removing dangling images"
    docker_remove_dangling_images
}

docker_copy_pkgmanager_conf() {
    # Copy over local package manager.conf ( specific for arch)
    if [ "${ARCH}" = "x86_64"  ]; then
        # AMD64 config
        if [ "${USE_STAGING}" = "yes" ]; then
            if [ "${USE_STAGING_LOCAL}" = "yes" ]; then
                docker_run_cmd $1 "cp -f /home/developer/$TOOL_MAIN_NAME/build/docker/developing/${PACKAGE_MANAGER}/staging_local_amd64_${PACKAGE_MANAGER}.conf /etc/${PACKAGE_MANAGER}.conf"
            else
                docker_run_cmd $1 "cp -f /home/developer/$TOOL_MAIN_NAME/build/docker/developing/${PACKAGE_MANAGER}/staging_amd64_${PACKAGE_MANAGER}.conf /etc/${PACKAGE_MANAGER}.conf"
            fi
        else
            docker_run_cmd $1 "cp -f /home/developer/$TOOL_MAIN_NAME/build/docker/developing/${PACKAGE_MANAGER}/stable_amd64_${PACKAGE_MANAGER}.conf /etc/${PACKAGE_MANAGER}.conf"
        fi
    elif [ "${ARCH}" = "aarch64"  ]; then
        # ARM64 config
        # For arm64 we always have staging right now
        docker_run_cmd $1 "cp -f /home/developer/$TOOL_MAIN_NAME/build/docker/developing/${PACKAGE_MANAGER}/arm64_${PACKAGE_MANAGER}.conf /etc/${PACKAGE_MANAGER}.conf"
        docker_run_cmd $1 "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
    fi
}
