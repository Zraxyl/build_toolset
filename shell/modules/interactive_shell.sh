##
# This module is responsible for spawning the interactive shell
##

# itshell = interactive shell

itshell_help() {
    message "##"
    message "# Interactive build shell help menu"
    message "##"

    msg_spacer

    echo "# Build commands"

    message "bc - This will build the package without docker option"
    message "example: 'bc linux glib2'"
    echo " "
    message "bcd - This will build the package with docker option ( non-kde )"
    message "example: 'bcd linux glib2'"
    echo " "
    message "bcdk - This will build the package with docker option ( kde )"
    message "example: 'bcdk plasma-desktop'"

    msg_spacer

    echo "# Docker shell"

    message "dshell - This will enter you to the build container ( Allows to do changes if needed )"
    message "example: 'dshell'"
    echo " "
    message "dkshell - This is same as dshell but for kde build container"
    message "example: 'dkshell'"

    msg_spacer

    echo "# Other"

    message "pkgedit - This will opne up kate with PKGBUILD issued by pkgname"
    message "example: 'pkgedit bash coreutils util-linux'"
    echo " "
    message "reload - reload all the toolset modules ( Allows to load in any changes )"
    message "example: 'reload'"

}

itshell_health_check() {
    # Check if current user from whoami has config files in place
    # If not then do it

    echo " "
}

itshell_shell() {
    # Make sure we remove reload tmp file if it exists
    if [ -f "${TOOL_OUT}/.ITSHELL_RELOAD" ]; then
        rm -f "${TOOL_OUT}/.ITSHELL_RELOAD"
    fi

    subshell=true bash --rcfile ${DEV_FOLDER}/base/bashrc
}

itshell_spawn_interactive_shell() {
    # Run health check
    itshell_health_check

    trap - SIGINT INT
    trap - ERR
    set +e

    rm -f ${TOOL_OUT}/.ITSHELL_RELOAD

    # Now spawn new bash shell with new bashrc that has aliases in place
    itshell_shell

    rm -f ${TOOL_OUT}/.ITSHELL_RELOAD

    set -e
}
