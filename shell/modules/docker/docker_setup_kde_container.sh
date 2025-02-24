##
# This is not a build container but a main kde!!!
#
# Not to be confused then this module creats base/kde from base container
# This container here will be updated exactly the same way as base ( + acts same too )
##

docker_check_kde_container() {
    sleep 1
    export CHECKIT3=$(sudo docker container ls -a | grep -wo $DOCKER_KDE_CONTAINER_NAME)

    if [ -z ${CHECKIT3} ]; then
        CHECKIT="empty"
    fi

    if [ "$CHECKIT3" = "$DOCKER_KDE_CONTAINER_NAME" ]; then
        message "KDE container already imported"
    else
        message "KDE container seems to be missing, so lets import it"
        docker_setup_kde
        docker_start_container $DOCKER_KDE_CONTAINER_NAME
    fi
}

docker_export_kde() {
    docker_export $DOCKER_BASE_CONTAINER_NAME $DOCKER_KDE_CONTAINER_NAME
}

docker_import_kde() {
    docker_import $DOCKER_KDE_CONTAINER_NAME
}

docker_setup_kde() {
    # Export base for kde container
    docker_export_kde

    # Import the exported container for kde
    docker_import_kde

    # Start container
    docker_start_container $DOCKER_KDE_CONTAINER_NAME

    # Run pre setup for kde container
    docker_kde_presetup

    # Update container
    docker_update_kde
}

# Install required packages for kde container
docker_kde_presetup() {
    # Reset pkg manager sync folder
    docker_run_cmd $DOCKER_KDE_CONTAINER_NAME "rm -rf /var/lib/${PACKAGE_MANAGER}/sync/*"

    docker_copy_pkgmanager_conf $DOCKER_KDE_CONTAINER_NAME

    # Make sure that container has sudo installed with
    docker_run_cmd $DOCKER_KDE_CONTAINER_NAME "${PACKAGE_MANAGER} --noconfirm --disable-download-timeout -Syyu --overwrite=*"
    docker_run_cmd $DOCKER_KDE_CONTAINER_NAME "${PACKAGE_MANAGER} --needed --noconfirm --disable-download-timeout -Sy ${DOCKER_PKG_KDE}"

    docker_copy_pkgmanager_conf $DOCKER_KDE_CONTAINER_NAME

    # Reset pkg manager sync folder
    docker_run_cmd $DOCKER_KDE_CONTAINER_NAME "rm -rf /var/lib/${PACKAGE_MANAGER}/sync/*"
}

# Always update the main container after updates to get the latest repo changes
docker_update_kde() {
    docker_copy_pkgmanager_conf $DOCKER_KDE_CONTAINER_NAME

    # Make sure that container has sudo installed
    docker_run_cmd $DOCKER_KDE_CONTAINER_NAME "${PACKAGE_MANAGER} --noconfirm --disable-download-timeout -Syu --overwrite=*"
    docker_run_cmd $DOCKER_KDE_CONTAINER_NAME "${PACKAGE_MANAGER} --noconfirm --disable-download-timeout --needed -Sy ${DOCKER_PKG} ${DOCKER_PKG_KDE}"
    docker_run_cmd $DOCKER_KDE_CONTAINER_NAME "${PACKAGE_MANAGER} --noconfirm --disable-download-timeout -S glibc"

    docker_copy_pkgmanager_conf $DOCKER_KDE_CONTAINER_NAME
}
