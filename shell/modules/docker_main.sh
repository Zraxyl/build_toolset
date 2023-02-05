##
# Here are functions related for docker functions
##

docker_initial_setup() {
    # Start dockerd from systemctl
    sudo systemctl restart docker

    if [ -f $P_ROOT/tools/checks/docker_ready ]; then
        drunk_debug "Docker image is already downloaded, starting the container now"
        drunk_message "Starting docker container ( sudo may be needed )"
        docker_container_start

        sleep 2

    else
        drunk_message "Docker initial setup will ask for passwd"
        sudo docker pull hilledkinged/drunk:latest

        sleep 1

        # Setup base docker container
        docker_setup_container

        # Start our new container
        docker_container_start

        sleep 1

        docker_initial_sysedit

        # Tell the script that docker image is pulled
        touch $P_ROOT/tools/checks/docker_ready

        docker_check_kde_health
    fi
}

docker_check_kde_health() {
    # Lets make a image from custom container
    if [ ! -f $P_ROOT/tools/checks/docker_kde_ready ]; then
        docker_run_cmd rm -rf /var/lib/bottle/sync/*
        docker_run_cmd bottle -Syu --needed --noconfirm --disable-download-timeout qt5 qt6

        drunk_message "Creating new image for drunk_kde"
        sudo docker commit $DOCKER_CONTAINER_NAME drunk_kde

        docker_reset
    fi
}

# Here are needed changes for our development area/env that arent made by default image builder
docker_initial_sysedit() {
    # Reset bottle sync folder
    docker_run_cmd rm -rf /var/lib/bottle/sync/*

    set +e

    # Add developer user ( used to build pkg's without root
    docker_run_cmd useradd developer -m -g wheel

    # Copy over local bottle.conf
    docker_run_cmd cp -f /home/developer/DRUNK/tools/docker/bottle.conf /etc/bottle.conf

    # Perms fixes + bottle changes
    docker_run_cmd bash -c /home/developer/DRUNK/tools/docker/developer.sh

    set -e

    # Also upgrade base system before installing new stuff
    docker_run_cmd bottle -Syu --needed --noconfirm --disable-download-timeout

    # Make sure that container has sudo installed with
    docker_run_cmd bottle --needed --noconfirm --disable-download-timeout -Sy sudo nano mpfr mpc base-devel m4 git grep gawk file

    docker_run_cmd bash -c /home/developer/DRUNK/tools/docker/fix_sudo.sh

    # Apply git global changes ( just in case repo tool is used somewhere )
    docker_run_cmd git config --global user.email "developer@drunk.com"
    docker_run_cmd git config --global user.name "Docker developer"
    docker_run_cmd git config --global color.ui false
}

docker_setup_container() {
    sudo docker container create \
    --name $DOCKER_CONTAINER_NAME \
    --volume $P_ROOT:$DOCKER_USER_FOLDER/DRUNK \
    --tty \
    hilledkinged/drunk /bin/bash
}

docker_setup_container_kde() {
    sudo docker container create \
    --name $DOCKER_CONTAINER_KDE_NAME \
    --volume $P_ROOT:$DOCKER_USER_FOLDER/DRUNK \
    --tty \
    drunk_kde /bin/bash
}

docker_container_start() {
    if [ "${DOCKER_CONTAINER_KDE}" = true ]; then
        docker_container_start_kde
    else
        docker_container_start_normal
    fi
}

docker_container_start_normal() {
    sudo docker start $DOCKER_CONTAINER_NAME >/dev/null
}

docker_container_start_kde() {
    sudo docker start $DOCKER_CONTAINER_KDE_NAME >/dev/null
}

docker_reset() {
    docker_set_kde_status

    if [ "${DOCKER_CONTAINER_KDE}" = true ]; then
        docker_reset_kde
    else
        docker_reset_dev
    fi

    drunk_message "Docker reset is done for: ${DOCKER_CONTAINER_KDE}"
}

docker_reset_dev() {
    drunk_message "Stopping old container ( drunk_dev )"

    sudo docker container stop $DOCKER_CONTAINER_NAME
    sleep 1

    sudo docker container rm $DOCKER_CONTAINER_NAME
    sleep 2

    docker_setup_container
    sleep 1

    sudo docker start $DOCKER_CONTAINER_NAME >/dev/null
    sleep 3

    docker_initial_sysedit

    # Now clean tmp
    clean_tmp
}

# Only applies for drunk_kde
docker_reset_kde() {
    drunk_message "Stopping old container ( drunk_kde )"

    sudo docker container stop $DOCKER_CONTAINER_KDE_NAME
    sleep 1

    sudo docker container rm $DOCKER_CONTAINER_KDE_NAME
    sleep 2

    docker_setup_container_kde
    sleep 1

    docker_container_start_kde
    sleep 3

    docker_initial_sysedit

    # Update / Upgrade qt*
    docker_run_cmd bottle --needed --noconfirm --disable-download-timeout -Su qt5 qt6

    # Now clean tmp
    clean_tmp
}

docker_set_kde_status() {
    drunk_debug "Getting proper container name for our usage"

    if [ ! -f $DRUNK_TEMP/docker001 ]; then
        touch $DRUNK_TEMP/docker001
    fi

    if [ "$(cat $DRUNK_TEMP/docker001)" == "kde_drunk_dev" ]; then
        echo 'true' > $P_ROOT/tools/checks/docker_kde
        export DOCKER_CONTAINER_NAME=${DOCKER_CONTAINER_KDE_NAME}
    else
        echo 'false' > $P_ROOT/tools/checks/docker_kde
    fi

    # Re-export the default container name ( basically overwrite default one to kde's )
    export DOCKER_CONTAINER_KDE=$(cat $P_ROOT/tools/checks/docker_kde)

    drunk_debug "KDE Switch is now: ${DOCKER_CONTAINER_KDE} + ${DOCKER_CONTAINER_NAME}"
}

# Start the container
docker_start() {
    drunk_debug "DOCKER: Executed bash shell"
    sudo docker exec --interactive --tty $DOCKER_CONTAINER_NAME bash
}

# ROOT run cmd
docker_run_cmd() {
    drunk_debug "DOCKER: $@"
    sudo docker exec --tty $DOCKER_CONTAINER_NAME $@
}

# developer user bash shell
docker_user_start() {
    drunk_debug "DOCKER: Executed bash shell"
    sudo docker exec --interactive --tty $DOCKER_CONTAINER_NAME su developer -c bash
}

# developer run cmd
docker_user_run_cmd() {
    drunk_debug "DOCKER: $@"
    sudo docker exec --tty $DOCKER_CONTAINER_NAME su developer -c "$@"
}

