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
}

itshell_health_check() {
    # Check if current user from whoami has config files in place
    # If not then do it

    echo " "
}

itshell_spawn_interactive_shell() {
    # Run health check
    itshell_health_check

    # Now spawn new bash shell with new bashrc that has aliases in place
    subshell=true bash --rcfile ${DEV_FOLDER}/base/bashrc
}
