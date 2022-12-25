check_and_setup_lock() {
    IS_COMPILING=none
    # Check wheather system has a lock on it or not
    if [ -f $DRUNK_TEMP/.drunk_locked ]; then
        if [ -f $DRUNK_TEMP/builds ]; then
            source $DRUNK_TEMP/builds
            drunk_warn Something is still compiling under background...
            drunk_err And that pkg name is: $IS_COMPILING
        else
            drunk_warn Something is still compiling under background...

            show_tmp_status

            drunk_err As we cant reach tmp files for proper specifications we just error out
        fi
    else
        # Lock the build system
        lock_drunk
    fi
}

show_tmp_status() {
    drunk_spacer
    drunk_message "These are the results of known files to lockup the builder"
    echo " "
    drunk_warn "File listing in tmp*"
    ls -a $DRUNK_TEMP/
    echo " "
    drunk_warn "Results of tmp/*"
    for f in $DRUNK_TEMP/* ; do
        drunk_warn "${f} : $(cat ${f})"
    done

    drunk_spacer
}

lock_drunk() {
    touch $DRUNK_TEMP/.drunk_locked
}
