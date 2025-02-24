##
# Basic checks and whatever else
#
# * I like my script head comments :)
##

repo_check_env() {
    # Firstly lets see if we are running in docker
    repo_fail_if_docker

    # Check weather we have full clone of distro repository
    # Or if we have one repo fully cloned then lets remember that
    repo_check_local_repositories

    # Check if creds have been added to local conf
    if [ $REPO_USER  = "none" ]; then
        msg_error "REPO_USER is empty"
    elif [ $REPO_IP = "none" ]; then
        msg_error "REPO_IP is empty"
    elif [ $REPO_TARGET_PATH  = "none" ]; then
        msg_error "REPO_TARGET_PATH is empty"
    fi
}
