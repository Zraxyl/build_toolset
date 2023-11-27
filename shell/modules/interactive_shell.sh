##
# This module is responsible for spawning the interactive shell
##

# itshell = interactive shell

itshell_help() {
    message "##"
    message "# Interactive build shell help menu"
    message "##"
    echo " "
    message "bc - This will build the package without docker option"
    message "example: 'bc linux glib2'"
    echo " "
    message "bcd - This will build the package with docker option ( non-kde )"
    message "example: 'bcd linux glib2'"
    echo " "
    message "bcdk - This will build the package with docker option ( kde )"
    message "example: 'bcdk plasma-desktop'"
    echo " "
    message "pkgedit - This will opne up kate with PKGBUILD issued by pkgname"
    message "example: 'pkgedit bash coreutils util-linux'"
}

itshell_health_check() {
    # Check if current user from whoami has config files in place
    # If not then do it

    echo " "
}

# Build packages locally without docker
itshell_pkgbuild_local() {
    export PKG_LIST=("${@}")

    build_pkg
}

# Build packages with docker
itshell_pkgbuild_docker() {
    export PKG_LIST=("${@}")

    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
        PKG_NAME=$(basename "${PKG_LIST[p]}")

        docker_user_run_cmd $DOCKER_BUILD_CONTAINER_NAME "cd ~/$TOOL_MAIN_NAME && ./envsetup --leave-tmp -b ${PKG_NAME}"


        message "BUILD: Starting to reset build container - CORE"
        sleep 5
        docker_build_base_reset
    done
}

# Build packages with docker ( KDE )
# KDE = qt5 and qt6 preinstalled
itshell_pkgbuild_docker_kde() {
    export PKG_LIST=("${@}")

    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
        PKG_NAME=$(basename "${PKG_LIST[p]}")

        docker_user_run_cmd $DOCKER_BUILD_CONTAINER_NAME_KDE "cd ~/$TOOL_MAIN_NAME && ./envsetup --leave-tmp -b ${PKG_NAME}"

        message "BUILD: Starting to reset build container - KDE"
        sleep 5

        docker_build_kde_reset
    done
}

itshell_pkgedit() {
    export PKG_LIST=("${@}")
    export PKGEDIT_LIST=" "

    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
        # Get current loop pkgname
        PKG_NAME=$(basename "${PKG_LIST[p]}")

        # Find the base dir of pkg
        find_pkg_location

        # Add the found pkg with dir to the variable
        export PKGEDIT_LIST+="${PKG_PATH}/PKGBUILD "
    done

    # Run them all with kate
    kate ${PKGEDIT_LIST}
}

itshell_spawn_interactive_shell() {
    # Run health check
    itshell_health_check

    trap - SIGINT INT
    trap - ERR
    set +e

    # Now spawn new bash shell with new bashrc that has aliases in place
    subshell=true bash --rcfile ${DEV_FOLDER}/base/bashrc

    set -e
}
