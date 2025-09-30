##
# Commonly used functions
##

# Restart docker ( even if its stopped already )
docker_start_service() {
    if [ ! -f $(which docker) ]; then
        msg_error "Docker is not installed/visible to the system/user"
    fi

    message "Starting docker service"
    # Start dockerd with systemctl
    sudo systemctl restart docker
}

# Check weather we are  in supported or foreign distro
docker_check_environment() {
    # Lets export ID_LIKE from os-release for the check
    export $(cat /etc/os-release | grep 'ID_LIKE=')
    #export ID_LIKE=force_docker

    # Usual check
    if [ "$(grep -q docker /proc/1/cgroup)" = "docker" ]; then
        msg_debug "Already running in docker env"
        export USE_DOCKER=false
    elif [ "${ID_LIKE}" = "${TOOL_TARGET_DISTRO}" ]; then
        message "Toolset will not use docker"
        export USE_DOCKER=false
        msg_debug "Docker use flag is: ${USE_DOCKER}"
    else
        message "Toolset will use the following image: ${TOOL_TARGET_DISTRO}"
        msg_debug "Docker use is ${USE_DOCKER}"
        export USE_DOCKER=true

        # TODO: Move out the iso stuff in docker common
        export DOCKER_FORCED_OPTION="iso_docker_cli"
    fi

    # Now lets unset the ID_LIKE env
    unset ID_LIKE
}

# Check if distro image has been pulled or not
docker_image_check() {
    docker_check_environment

    if [ "${USE_DOCKER}" = "false" ]; then
        docker_start_service

        export IS_MISSING=$(sudo docker image ls -a | grep -o ${DOCKER_IMAGE_NAME})

        # Check for existing image download
        if [[ "${IS_MISSING}" = "${DOCKER_IMAGE_NAME}" ]]; then
            message "Base Image has already been pulled, skipping..."
        else
            message "Pulling base image"
            if [ "${P_ARCH}" = "aarch64" ]; then
                msg_error "${P_ARCH} docker image does not exist yet"
                sudo docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH}
            else
                sudo docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_ARCH}
            fi
        fi
        unset IS_MISSING
    fi
}

# Create simple container with required paths and everything
# ARG 1 = container name
# ARG 2 = from which image container will be made
docker_create_container() {
    message "Creating ${1} container from ${2}"
    sudo docker container create \
    --name $1 \
    --volume $P_ROOT:$DOCKER_USER_FOLDER/$TOOL_MAIN_NAME \
    --tty \
    --privileged \
    -e LD_LIBRARY_PATH="/lib:/lib64:/usr/lib:/usr/lib64" \
    -e PATH="/bin:/sbin:/usr/bin:/usr/sbin" \
    ${2} /usr/bin/bash

    msg_debug "List of current containers"
    msg_debug "$(sudo docker container ls -a)"

    message "Cntainer has been made"
}

# Sometimes our containers need to be fixed so we run essential stuff before
# running any other commands ( example aarch64 wants ldconfig -r to be runned, otherwise
# we get some errors about libs not found )
docker_run_essentials() {
    msg_debug "DOCKER: Updating target ldconfig"

    # Update ldconfig cache
    sudo docker exec -u root --interactive $1 bash -c "ldconfig"
}

# Start target container
docker_start_container() {
    msg_debug "Starting container: $1"

    if [ "$SHOW_DEBUG" = "true" ]; then
        sudo docker start $1
    else
        sudo docker start $1 &> /dev/null
    fi
}

# Stop target container
docker_stop_container() {
    msg_debug "Stopping container: $1"
    if [ "$SHOW_DEBUG" = "true" ]; then
        sudo docker stop $1
    else
        sudo docker stop $1 &> /dev/null
    fi
}

# Remove target container
docker_remove_container() {
    docker_stop_container $1
    sudo docker container rm -f $1
}

# Remove target image
docker_remove_image() {
    docker_stop_container $1
    sudo docker image rm -f $1
}

# Remove dangling images
docker_remove_dangling_images() {
    sudo docker rmi $(sudo docker images --filter "dangling=true" -q --no-trunc)
}

# Run cmd in target container as root user
docker_run_cmd() {
    docker_start_container $1

    msg_debug "DOCKER: $2"
    sudo docker exec -u root --interactive $1 bash -c "$2"
}

# Run cmd in target container as developer user
docker_user_run_cmd() {
    docker_start_container $1

    msg_debug "DOCKER: $2"
    sudo docker exec -u developer --interactive $1 bash -c "$2"
}

docker_container_sysedit() {
    # Run Essentials before anything else
    docker_run_essentials $1

    # Reset pkg manager sync folder
    docker_run_cmd ${1} "rm -rf /var/lib/${PACKAGE_MANAGER}/sync/*"

    # Add developer user ( used to build pkg's without root
    docker_run_cmd ${1} "useradd developer -G adm,wheel -d /home/developer -M -s /usr/bin/bash"

    # Give users passwd so su dosent whine about auth info issues
    docker_run_cmd ${1} 'echo "root:toor" | chpasswd'
    docker_run_cmd ${1} 'echo "developer:developer" | chpasswd'

    # Copy over required bottle conf
    docker_copy_pkgmanager_conf ${1}

    # Perms fixes + ${PACKAGE_MANAGER} changes
    docker_run_cmd ${1} "bash -c /home/developer/$TOOL_MAIN_NAME/build/docker/developing/rootsys/developer.sh"

    # Also upgrade base system before installing new stuff
    docker_run_cmd ${1} "${PACKAGE_MANAGER} -Syy"
    docker_run_cmd ${1} "${PACKAGE_MANAGER} -Syu --noconfirm --disable-download-timeout --overwrite=*"

    # Rerun Essentials
    docker_run_essentials $1

    # Copy over required bottle conf
    docker_copy_pkgmanager_conf ${1}

    # Make sure that container has sudo installed with
    docker_run_cmd ${1} "${PACKAGE_MANAGER} --needed --noconfirm --disable-download-timeout -Syy ${DOCKER_PKG}"
    docker_run_cmd ${1} "${PACKAGE_MANAGER} --noconfirm --disable-download-timeout -S glibc systemd sudo"

    # Copy over required bottle conf
    docker_copy_pkgmanager_conf ${1}

    # Sudoers failsafe
    docker_run_cmd ${1} "bash -c /home/developer/$TOOL_MAIN_NAME/build/docker/developing/sudo/fix_sudo.sh"

    # Apply git global changes ( just in case repo tool is used somewhere )
    docker_run_cmd ${1} "git config --global user.email 'developer@zraxyl.com'"
    docker_run_cmd ${1} "git config --global user.name 'Docker developer'"
    docker_run_cmd ${1} "git config --global color.ui false"

    # Reset pkg manager sync folder
    docker_run_cmd ${1} "rm -rf /var/lib/${PACKAGE_MANAGER}/sync/*"
}
