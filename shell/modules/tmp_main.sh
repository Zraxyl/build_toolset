create_tmp() {
    # Create tmp folder
    mkdir -p $TOOL_TEMP

    sudo chmod -R a+rw $TOOL_TEMP
}

as_root_del() {
    # Lets made 'sudo rm -rf' bit safer
    if [ "$1" = / ]; then
        message_error "Welp, I almost deleted /"
    elif [ "$1" = /home ]; then
        message_error "Welp, I almost deleted /home"
    elif [ "$1" = /mnt ]; then
        message_error "Welp, I almost deleted /mnt"
    elif [ "$1" = /usr ]; then
        message_error "Welp, I almost deleted /usr"
    else
        sudo rm -rf "${1}"
    fi
}

as_user_del() {
    # Lets made 'sudo rm -rf' bit safer
    if [ "$1" = / ]; then
        message_error "Welp, I almost deleted /"
    elif [ "$1" = /home/$(whoami) ]; then
        message_error "Welp, I almost deleted /home"
    elif [ "$1" = /home/$(whoami)/Desktop ]; then
        message_error "Welp, I almost deleted ~/Desktop"
    elif [ "$1" = /mnt ]; then
        message_error "Welp, I almost deleted /mnt"
    else
        rm -rf "${1}"
    fi
}

clean_tmp() {
    # Clean tmp
    if [ -f $TOOL_TEMP/.keep_tmp ]; then
        msg_debug "Skipping tmp cleaning"
    else
        as_root_del $TOOL_TEMP
    fi
}

# Force clean can be used when certain functions cant use normal clean_tmp
force_clean_tmp() {
    # Just a failsafe where we wont remove tmp inside docker env
    if [ ! -d /home/developer ]; then
        as_root_del $TOOL_TEMP
    fi
}
