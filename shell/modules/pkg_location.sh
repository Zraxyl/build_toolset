##
# This module will make sure to feed others correct pkg location
# Mainly used by builder and cleaner
##

find_pkg_location() {
    # Look up the package directory
    PKG_ROOT_DIR=$P_ROOT/internal/pkgbuild/$P_ARCH

    message $PKG_ROOT_DIR

    ##
    # TODO: Make sure to find correct folder as some packages have similar names ( and this can make find select wrong dir )
    # PKG_PATH=$(find $PKG_ROOT_DIR -type d -path "$PKG_NAME")
    # So the if and elif under this comment can bre removed
    ##

    if [ -d $PKG_ROOT_DIR/core/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/core/$PKG_NAME
        export WHAT_AM_I=core
    elif [ -d $PKG_ROOT_DIR/kde/frameworks/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/frameworks/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/graphics/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/graphics/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/kdevelop/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/kdevelop/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/libraries/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/libraries/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/multimedia/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/multimedia/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/neon/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/neon/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/network/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/network/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/other/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/other/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/plasma/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/plasma/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/sdk/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/sdk/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/system/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/system/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/kde/utilities/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/kde/utilities/$PKG_NAME
        export WHAT_AM_I=kde
    elif [ -d $PKG_ROOT_DIR/cross-tools/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/cross-tools/$PKG_NAME
        export WHAT_AM_I=cross-tools
    elif [ -d $PKG_ROOT_DIR/gnome/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/gnome/$PKG_NAME
        export WHAT_AM_I=gnome
    elif [ -d $PKG_ROOT_DIR/xfce/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/xfce/$PKG_NAME
        export WHAT_AM_I=xfce
    elif [ -d $PKG_ROOT_DIR/extra/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/extra/$PKG_NAME
        export WHAT_AM_I=extra
    elif [ -d $PKG_ROOT_DIR/extra32/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/extra32/$PKG_NAME
        export WHAT_AM_I=extra32
    elif [ -d $PKG_ROOT_DIR/games/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/games/$PKG_NAME
        export WHAT_AM_I=games
    elif [ -d $PKG_ROOT_DIR/layers/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/layers/$PKG_NAME
        export WHAT_AM_I=layers
    elif [ -d $PKG_ROOT_DIR/pentest/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/pentest/$PKG_NAME
        export WHAT_AM_I=pentest
    elif [ -d $PKG_ROOT_DIR/perl/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/perl/$PKG_NAME
        export WHAT_AM_I=perl
    elif [ -d $PKG_ROOT_DIR/proprietary/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/proprietary/$PKG_NAME
        export WHAT_AM_I=proprietary
    elif [ -d $PKG_ROOT_DIR/python/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/python/$PKG_NAME
        export WHAT_AM_I=python
    elif [ -d $PKG_ROOT_DIR/server/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/server/$PKG_NAME
        export WHAT_AM_I=server
    elif [ -d $PKG_ROOT_DIR/fonts/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/fonts/$PKG_NAME
        export WHAT_AM_I=extra
    elif [ -d $PKG_ROOT_DIR/java/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/java/$PKG_NAME
        export WHAT_AM_I=extra
    elif [ -d $PKG_ROOT_DIR/xorg/app/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/xorg/app/$PKG_NAME
        export WHAT_AM_I=extra
    elif [ -d $PKG_ROOT_DIR/xorg/data/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/xorg/data/$PKG_NAME
        export WHAT_AM_I=extra
    elif [ -d $PKG_ROOT_DIR/xorg/driver/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/xorg/driver/$PKG_NAME
        export WHAT_AM_I=extra
    elif [ -d $PKG_ROOT_DIR/xorg/libs/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/xorg/libs/$PKG_NAME
        export WHAT_AM_I=extra
    elif [ -d $PKG_ROOT_DIR/xorg/proto/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/xorg/proto/$PKG_NAME
        export WHAT_AM_I=extra
    elif [ -d $PKG_ROOT_DIR/xorg/xserver/$PKG_NAME ]; then
        export PKG_PATH=$PKG_ROOT_DIR/xorg/xserver/$PKG_NAME
        export WHAT_AM_I=extra
    else
        msg_error "$PKG_NAME was not found ( check for typos or if its new category then remember to add entry for it in builder modules )"
        msg_error "Issue may also occure if you forgot to mention arch ( see --help )"
	clean_tmp
    fi

    msg_debug "Pkg is located at $PKG_PATH"
}
