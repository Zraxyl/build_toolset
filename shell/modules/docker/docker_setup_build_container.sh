docker_check_build_container() {
    if [ "$(sudo docker container ls -a | grep -wo $DOCKER_BUILD_CONTAINER_NAME)" = "$DOCKER_BUILD_CONTAINER_NAME" ]; then
        message "Build container already imported, so lets skip"
    else
        message "Build container seems to be missing, so lets import it"
        docker_build_setup
        docker_start_container $DOCKER_BUILD_CONTAINER_NAME

    fi
}

docker_export_base() {
    docker_export $DOCKER_BASE_CONTAINER_NAME $DOCKER_BUILD_CONTAINER_NAME
}

docker_import_build() {
    docker_import $DOCKER_BUILD_CONTAINER_NAME
}

docker_build_setup() {
    # Export base for build container
    docker_export_base

    # Import the exported container for build
    docker_import_build
}

docker_build_base_reset() {
    docker_remove_container $DOCKER_BUILD_CONTAINER_NAME

    # Before exporting and importing lets update the base container
    docker_base_update

    docker_build_setup
}
