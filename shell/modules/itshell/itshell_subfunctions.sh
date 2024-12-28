##
# Interactive shell subfunctions
# - This sub-module includes all the subfunctions for aliases
##

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

    # Run them all with text editor
    ${TEXT_EDITOR} ${PKGEDIT_LIST}
}

itshell_reload() {
    # This subfunction will reload all of the toolset modules in the background + restarts the shell

    if [ -f ${TOOL_OUT}/.ITSHELL_RELOAD ]; then
        as_user_del ${TOOL_OUT}/.ITSHELL_RELOAD
        itshell_spawn_interactive_shell
    fi

    # Here we wanna be hold on exit so when user quits another subshell
    # then all the ones that are on hold will eventually exit
    exit &> /dev/null
}
