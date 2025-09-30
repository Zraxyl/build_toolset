docker_check_build_container_kde() {
    sleep 1
    export CHECKIT2=$(sudo docker container ls -a | grep -wo $DOCKER_BUILD_CONTAINER_NAME_KDE)

    if [ -z ${CHECKIT2} ]; then
        export CHECKIT2="empty"
    fi

    if [ "${CHECKIT2}" = "$DOCKER_BUILD_CONTAINER_NAME_KDE" ]; then
        message "KDE build container already imported, so lets skip"
    else
        message "KDE build container seems to be missing, so lets import it"
        docker_kde_build_setup
        docker_start_container $DOCKER_BUILD_CONTAINER_NAME_KDE

    fi

    unset CHECKIT2
}

docker_export_kde_container() {
    docker_export $DOCKER_KDE_CONTAINER_NAME $DOCKER_BUILD_CONTAINER_NAME_KDE
}

docker_import_kde_build_container() {
    docker_import $DOCKER_BUILD_CONTAINER_NAME_KDE
}

docker_kde_build_setup() {
    # Export base for build container
    docker_export_kde_container

    # Import the exported container for build
    docker_import_kde_build_container
}

docker_build_kde_reset() {
    docker_remove_container $DOCKER_BUILD_CONTAINER_NAME_KDE

    # Before exporting and importing lets update the kde base container
    docker_update_kde

    docker_kde_build_setup
}

# Mainly used by pkg_build module to choose correct container for builds
docker_check_if_kde() {
    if [ ! -f $TOOL_TEMP/docker001 ]; then
        touch $TOOL_TEMP/docker001
    fi

    if [ "$(cat $TOOL_TEMP/docker001)" = "$DOCKER_BUILD_CONTAINER_NAME_KDE" ]; then
        echo 'true' > $TOOL_CHECKS/docker_kde
    else
        echo 'false' > $TOOL_CHECKS/docker_kde
    fi
}
