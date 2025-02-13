docker_check_base_container() {
    sleep 1
    export CHECKIT4=$(sudo docker container ls -a | grep -wo ${DOCKER_IMAGE_NAME})

    if [ -z ${CHECKIT4} ]; then
        CHECKIT="empty"
    fi

    if [ "${CHECKIT4}" = "${DOCKER_IMAGE_NAME}" ]; then
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

    export UNI_PASSWORD=$(echo toor | openssl passwd -1 -stdin)

    # Add developer user ( used to build pkg's without root
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "useradd developer -m -g wheel"

    docker_copy_pkgmanager_conf $DOCKER_BASE_CONTAINER_NAME

    # Give users passwd so su dosent whine about auth info issues
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "usermod --password $UNI_PASSWORD root"
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "usermod --password $UNI_PASSWORD developer"

    # Perms fixes + ${PACKAGE_MANAGER} changes
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "bash -c /home/developer/$TOOL_MAIN_NAME/build/docker/developing/rootsys/developer.sh"

    set -e

    # Also upgrade base system before installing new stuff
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "${PACKAGE_MANAGER} -Syy"
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "${PACKAGE_MANAGER} -Syu --noconfirm --disable-download-timeout --overwrite=*"

    docker_copy_pkgmanager_conf $DOCKER_BASE_CONTAINER_NAME

    # Make sure that container has sudo installed with
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "${PACKAGE_MANAGER} --needed --noconfirm --disable-download-timeout -Sy ${DOCKER_PKG}"
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "${PACKAGE_MANAGER} --noconfirm --disable-download-timeout -S glibc systemd"

    docker_copy_pkgmanager_conf $DOCKER_BASE_CONTAINER_NAME

    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "bash -c /home/developer/$TOOL_MAIN_NAME/build/docker/developing/sudo/fix_sudo.sh"

    # Apply git global changes ( just in case repo tool is used somewhere )
    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "git config --global user.email 'developer@zraxyl.com'"
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
    -e LD_LIBRARY_PATH="/lib:/lib64:/usr/lib:/usr/lib64" \
    -e PATH="/bin:/sbin:/usr/bin:/usr/sbin" \
    ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH} /bin/bash
    message "Base container created"
}

# Runs base container updates
docker_base_update() {
    docker_start_container $DOCKER_BASE_CONTAINER_NAME

    docker_copy_pkgmanager_conf $DOCKER_BASE_CONTAINER_NAME

    docker_run_cmd $DOCKER_BASE_CONTAINER_NAME "${PACKAGE_MANAGER} -Syu --needed --noconfirm --disable-download-timeout --overwrite=*"

    docker_copy_pkgmanager_conf $DOCKER_BASE_CONTAINER_NAME
}
