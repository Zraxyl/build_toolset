##
# Here will be the common functions that are used by other repo modules
##

repo_fail_if_docker() {
    # Run the basic docker check
    if [ "$(grep -q docker /proc/1/cgroup)" = "docker" ]; then
        msg_error "Repo tool wont run inside the docker containers currently.."
    fi
}

# Check and remember which local repositories we have
repo_check_local_repositories() {
    msg_spacer
    message "Checking for available repositories"
    for repo_type in ${REPO_LIST}; do
        repo_path="${REPO_LOCAL_PATH}/${repo_type}"
        if [ -d "$repo_path" ]; then
            message "Repo ${repo_type} has been found"

            # Make an list of available repos
            export REPO_LOCAL_LIST+=" ${repo_type}"
        fi
    done
    msg_spacer
}

# method-1: Upload/Sync files with rsync
repo_upload_rsync() {
    ##
    # 1 = src
    # 2 = target host name
    # 3 = target host IP
    # 4 = target host path
    rsync -a -P -essh ${1} ${2}@${3}:${4}
}
