##
# Here we will declare function how and where to clean pkg's
##

# Hilledkinged
# TODO: why, what, when did this happen to be added into TODO
clean_pkg() {
    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
    PKG_NAME=$(basename "${PKG_LIST[p]}")

    msg_debug "CLEANER: Executed"

    find_pkg_location

    cd $PKG_PATH

    if [ -f PKGBUILD  ]; then
        msg_debug "Found correct directory with PKGBUILD"
    else
        msg_error "directory or PKGBUILD is missing for asked pkg"
        clean_tmp
    fi

    if [ -d src ]; then
        msg_debug "$PKG_NAME has been selected for cleaning"
    else
        msg_error "$PKG_NAME isn't dirty, meaning we will not clean it!"
        clean_tmp
    fi

    # Cleanup everything
    as_user_del pkg/ src/ *pkg* *xz* *tar.gz *tar.bz2 *.zip */ *tgz *tar.zst *sign* *sig* *asc*

    message "$PKG_NAME has been cleaned"

    # Clean tmp
    clean_tmp

    done
}

# Hilledkinged
# TODO: Huh, this needs to be looked up ( ancient code that even I dont wanna touch )
clean_pkg_docker() {
    docker_initial_setup

    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
    PKG_NAME=$(basename "${PKG_LIST[p]}")

    message "DOCKER: $PKG_NAME has been selected for cleaning"
    docker_user_run_cmd "cd ~/$TOOL_MAIN_NAME && ./envsetup -c ${PKG_NAME}"

    # clean tmp
    clean_tmp
    done
}
