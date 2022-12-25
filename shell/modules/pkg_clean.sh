##
# Here we will declare function how and where to clean pkg's
##

# TODO
clean_pkg() {
    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
    PKG_NAME=$(basename "${PKG_LIST[p]}")

    drunk_debug "CLEANER: Executed"

    find_pkg_location

    cd $PKG_PATH

    if [ -f PKGBUILD  ]; then
        drunk_debug "Found correct directory with PKGBUILD"
    else
        drunk_err "directory or PKGBUILD is missing for asked pkg"
        clean_tmp
    fi

    if [ -d src ]; then
        drunk_debug "$PKG_NAME has been selected for cleaning"
    else
        drunk_err "$PKG_NAME isn't dirty, meaning we will not clean it!"
        clean_tmp
    fi

    # Cleanup everything
    rm -rf pkg/ src/ *pkg* *xz* *tar.gz *tar.bz2 *.zip */ *tgz *tar.zst *sign* *sig* *asc*

    drunk_message "$PKG_NAME has been cleaned"

    # Clean tmp
    clean_tmp

    done
}

clean_pkg_docker() {
    docker_initial_setup

    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
    PKG_NAME=$(basename "${PKG_LIST[p]}")

    drunk_message "DOCKER: $PKG_NAME has been selected for cleaning"
    docker_user_run_cmd "cd ~/DRUNK && ./drunk -c ${PKG_NAME}"

    # clean tmp
    clean_tmp
    done
}
