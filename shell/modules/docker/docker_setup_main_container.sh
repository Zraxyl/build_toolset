docker_check_base_container() {
    if [ "$(sudo docker container ls -a | grep -wo hilledkinged/evolinx)" = "hilledkinged/evolinx" ]; then
        message "Base container already made"
    else
        message "base container seems to be missing, so lets make it"
        docker_create_base_container
        docker_start_container $DOCKER_BASE_CONTAINER_NAME
        docker_base_container_sysedit
    fi
}

docker_base_container_sysedit() {
    # Reset pkg manager sync folder
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "rm -rf /var/lib/${PACKAGE_MANAGER}/sync/*"

    set +e

    # Add developer user ( used to build pkg's without root
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "useradd developer -m -g wheel"

    docker_copy_pkgmanager_conf $DOCKER_BASE_CONTAINER_NAME

    # Perms fixes + ${PACKAGE_MANAGER} changes
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "bash -c /home/developer/$TOOL_MAIN_NAME/build/docker/developing/rootsys/developer.sh"

    set -e

    # Also upgrade base system before installing new stuff
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "${PACKAGE_MANAGER} -Syu --needed --noconfirm --disable-download-timeout"

    docker_copy_pkgmanager_conf $DOCKER_BASE_CONTAINER_NAME

    # Make sure that container has sudo installed with
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "${PACKAGE_MANAGER} --needed --noconfirm --disable-download-timeout -Sy linux ${DOCKER_PKG}"

    docker_copy_pkgmanager_conf $DOCKER_BASE_CONTAINER_NAME

    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "bash -c /home/developer/$TOOL_MAIN_NAME/build/docker/developing/sudo/fix_sudo.sh"

    # Apply git global changes ( just in case repo tool is used somewhere )
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "git config --global user.email 'developer@evolix.com'"
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "git config --global user.name 'Docker developer'"
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "git config --global color.ui false"

    # Reset pkg manager sync folder
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "rm -rf /var/lib/${PACKAGE_MANAGER}/sync/*"
}

# Creates base container from base image
docker_create_base_container() {
    message "Creating base container"
    sudo docker container create \
    --name $DOCKER_BASE_CONTAINER_NAME \
    --volume $P_ROOT:$DOCKER_USER_FOLDER/$TOOL_MAIN_NAME \
    --tty \
    ${DOCKER_IMAGE_NAME} /bin/bash
    message "Base container created"
}

# Runs base container updates
docker_base_update() {
    docker_start_container $DOCKER_BASE_CONTAINER_NAME

    docker_copy_pkgmanager_conf $DOCKER_BASE_CONTAINER_NAME

    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "${PACKAGE_MANAGER} -Syu --needed --noconfirm --disable-download-timeout"

    docker_copy_pkgmanager_conf $DOCKER_BASE_CONTAINER_NAME
}
