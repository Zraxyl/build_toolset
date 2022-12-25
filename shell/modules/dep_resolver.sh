##
# Here we will try to lookup what depends on what and what makedepend pkg's we need to install
##

resolve_dep() {
    drunk_debug "DEP-Resolver looks for $PKG_NAME pkg"

    cd $PKG_PATH

    source PKGBUILD

    drunk_debug "DEPENDS LIST: ${depends[*]}"
    drunk_debug "MAKEDEPENDS List: ${makedepends[*]}"

    export PKG_VERSION=$pkgver
    export PKG_REL=$pkgrel
    export FULL_DEP_LIST="${depends[*]} ${makedepends[*]}"
}

install_dep() {
    drunk_message "Bottle will install these dependencies ' $FULL_DEP_LIST '"

    # Lets do a hack here with lock
    # TODO: Somehow check if pkg got installed and if not then exit and clear tmp ( otherwise it just errors and dosent remve lock )
    rm $DRUNK_TEMP/.drunk_locked
    drunk_spacer
    sudo -S bottle -Syu --needed --noconfirm --disable-download-timeout $FULL_DEP_LIST
    drunk_spacer
    touch $DRUNK_TEMP/.drunk_locked
}
