create_tmp() {
    # Create tmp folder
    mkdir -p $DRUNK_TEMP
}

clean_tmp() {
    # Clean tmp
    if [ -f $DRUNK_TEMP/.keep_tmp ]; then
        drunk_debug "Skipping tmp cleaning"
    else
        rm -rf $DRUNK_TEMP
    fi
}
