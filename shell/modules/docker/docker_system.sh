##
# Docker main system functions
# This place extends existing docker functions for build systems and etc
##

docker_check_health() {
    message "Starting docker health check"
    # Remove docker check as we need to recheck docker health
    rm -f $TOOL_CHECKS/docker_ready

    # Check image health
    # 1: If missing then pull
    # 2: If exists then its all good
    message "Docker image health check"
    docker_image_check

    # Check base container health
    # 1: If missing then make one
    # 2: If exists then update it
    message "Docker base container check"
    docker_check_base_container

    # Check kde main container health ( not for build usage)
    # 1: If missing then make one
    # 2: If exists then update it
    message "Docker kde container check"
    docker_check_kde_container

    # Check build container health
    # 1: If missing then make one
    # 2: If exists then update it
    # 3: If build is done then trigger base update and re-create build container
    message "Docker build container check"
    docker_check_build_container

    # Check kde build container health
    # 1: If missing then make one
    # 2: If exists then update it
    # 3: If build is done then trigger kde update and re-create kde build container
    message "Docker kde build container check"
    docker_check_build_container_kde

    echo 1 > $TOOL_CHECKS/docker_ready
    message "Health check passed"
}

docker_shell_session() {
    docker_check_if_kde

    if [ "$(cat $TOOL_CHECKS/docker_kde)" = "true" ]; then
        docker_start_container $DOCKER_BUILD_CONTAINER_NAME_KDE
        docker_run_cmd $DOCKER_BUILD_CONTAINER_NAME_KDE "bash"
        docker_stop_container $DOCKER_BUILD_CONTAINER_NAME_KDE

        force_clean_tmp

        exit
    else
        docker_start_container $DOCKER_BUILD_CONTAINER_NAME
        docker_run_cmd $DOCKER_BUILD_CONTAINER_NAME "bash"
        docker_stop_container $DOCKER_BUILD_CONTAINER_NAME

        force_clean_tmp

        exit
    fi
}

docker_reset_build() {
    docker_check_if_kde

    if [ "$(cat $TOOL_CHECKS/docker_kde)" = "true" ]; then
        docker_build_kde_reset
    else
        docker_build_base_reset
    fi
}
