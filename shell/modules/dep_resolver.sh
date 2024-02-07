##
# Here we will try to lookup what depends on what and what makedepend pkg's we need to install
##

resolve_dep() {
    msg_debug "DEP-Resolver looks for $PKG_NAME pkg"

    cd $PKG_PATH

    source PKGBUILD

    msg_debug "DEPENDS LIST: ${depends[*]}"
    msg_debug "MAKEDEPENDS List: ${makedepends[*]}"

    export PKG_VERSION=$pkgver
    export PKG_REL=$pkgrel
    export FULL_DEP_LIST="${depends[*]} ${makedepends[*]}"
}

install_dep() {
    message "Bottle will install these dependencies ' $FULL_DEP_LIST '"

    # Lets do a hack here with lock
    # TODO: Somehow check if pkg got installed and if not then exit and clear tmp ( otherwise it just errors and dosent remve lock )
    rm -f $TOOL_TEMP/.builder_locked
    msg_spacer

    # HACK: AMD64 port always needs linux package as it has headers where aarch64 port has linux-headers package
    if [ "${P_ARCH}" = "aarch64" ]; then
        sudo bottle -Syu --needed --noconfirm --disable-download-timeout base-dev linux-headers $FULL_DEP_LIST
    else
        sudo bottle -Syu --needed --noconfirm --disable-download-timeout base-dev linux $FULL_DEP_LIST
    fi

    msg_spacer
    touch $TOOL_TEMP/.builder_locked
}
