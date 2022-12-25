interrupt_handle() {
    clean_tmp
    drunk_warn POSSIBLE CRASH/ERROR CAUSED BY CTRL+C / INTERRUPT
    sleep 1

    exit
}

exit_handle() {
    clean_tmp
    drunk_debug $?
    drunk_warn SCRIPT EXITED

    exit
}

# Untils logging issue is fixed
tmp_err_handle() {
    drunk_warn Script had a error so we need to exit by cleaning tmp files
    clean_tmp
    drunk_err Bye
}

err_handle() {
    # Post error message with cathered log
    fault_log=$( tail "$DRUNK_TEMP/drunk_err.log" )

    drunk_spacer
    drunk_fault $fault_log
    drunk_spacer

    cp $DRUNK_TEMP/drunk_err.log $P_ROOT/build_error.log
    clean_tmp
    sleep 2

    exit
}

start_logging() {
    # Setup logging
    local err_code="${1:-$?}"

    touch $DRUNK_TEMP/drunk_err.log
    declare err_log=$DRUNK_TEMP/drunk_err.log

    # Log error messages
    #exec 2> $err_log
    exec 2> $err_log
    exec 3>&-
}
