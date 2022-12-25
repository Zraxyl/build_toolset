##
# Here we will declare function how and where to work with pkg's
##

build_pkg() {
    drunk_debug "EXECUTED - Build pkg"

    # Source some env build flags
    if [[ -f $DRUNK_TEMP/envvar00* ]]; then
        source $DRUNK_TEMP/envvar001 # Specifies if pkgrel bumping is needed ( if not then true for skip )
    fi

    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
        PKG_NAME=$(basename "${PKG_LIST[p]}")

        # Update ic_compiling ( used for lock function to notify user what is WIP currently )
        rm -f $DRUNK_TEMP/builds # remove it even if it dosent exist
        echo "IS_COMPILING=${PKG_NAME}" > $DRUNK_TEMP/builds

        # Just in case if no -f / --no-extract has been specified
        touch $DRUNK_TEMP/tmpvar999
        MAKEPKG_EXTRA_ARG="$(cat $DRUNK_TEMP/tmpvar* | tr -d '\n' )"

        echo " " # hacky Newline?
        drunk_debug ---
        drunk_debug // Specified makepkg "flag's"
        drunk_debug $MAKEPKG_EXTRA_ARG
        drunk_debug ---
        echo " " # hacky Newline?

        # Find its location
        find_pkg_location

        cd $PKG_PATH

        if [ -f PKGBUILD  ]; then
            drunk_debug "Found correct directory with PKGBUILD"
        else
            drunk_err "directory or PKGBUILD is missing for asked pkg"
        fi

        if [ "$DRUNK_SKIPBUMP" = false ];then
            # Make a copy of PKGBUILD for release ver bumper
            cp PKGBUILD PKGBUILD_NEW
            bump_rel
        fi

        sleep 1
        # Resolve + install needed deps of this pkg
        resolve_dep
        install_dep

        drunk_spacer

        drunk_debug ---
        drunk_debug // BASIC ORIG INFO
        drunk_debug PKGNAME=$pkgname
        drunk_debug PKGVER=$pkgver
        drunk_debug PKGREL=$pkgrel
        drunk_debug ---
        echo " " # hacky Newline?

        # Lets allow error's here ( we handle it by diff )
        set +e

        # Remove existing *pkg* file
        rm -f ${PKG_NAME}-*.pkg.tar.gz

        # Start the compiler for pkg
        # ( LC_CTYPE export is needed for bsdtar, without it we get error's about it for some tarballs )
        if [ "$DRUNK_SKIPBUMP" = false ];then
            LC_CTYPE=en_US.UTF-8 makepkg -p PKGBUILD_NEW $MAKEPKG_EXTRA_ARG

            #Now as the build finished we move our new PKGBUILD here
            cp -f PKGBUILD_NEW PKGBUILD
            rm -f PKGBUILD_NEW
        else
            LC_CTYPE=en_US.UTF-8 makepkg $MAKEPKG_EXTRA_ARG
        fi

        # Cleaning temp is needed, otherwise we have lock on and new compile of pkg cant be started ( basically clean on error here )
        echo $DRUNK_SKIPBUMP
        if [ "$DRUNK_SKIPBUMP" = false ];then
            if [ -f $PKG_NAME-$PKG_VERSION-$srel-$P_ARCH.pkg.tar.gz ]; then
                drunk_debug pkg got compiled
            else
                clean_tmp
                drunk_err pkg didnt compile, now error!
            fi
        else
            if [ -f $PKG_NAME-$PKG_VERSION-$pkgrel-$P_ARCH.pkg.tar.gz ]; then
                drunk_debug pkg got compiled
            else
                clean_tmp
                drunk_err pkg didnt compile, now error!
            fi
        fi

        set -e
        drunk_spacer

        if [ "$DRUNK_SKIPBUMP" = false ];then
            cp -f $PKG_NAME-$PKG_VERSION-$srel-$P_ARCH.pkg.tar.gz $P_ROOT/pkgbuild/pkgs/$WHAT_AM_I/
            # Tell dev where the pkg is located
            drunk_message "Build successfully done, and pkg file is located at pkgbuild/pkgs/$WHAT_AM_I/$PKG_NAME-$PKG_VERSION-$srel-$P_ARCH.pkg.tar.gz"
        else
            cp -f $PKG_NAME-$PKG_VERSION-$pkgrel-$P_ARCH.pkg.tar.gz $P_ROOT/pkgbuild/pkgs/$WHAT_AM_I/
            # Tell dev where the pkg is located
            drunk_message "Build successfully done, and pkg file is located at pkgbuild/pkgs/$WHAT_AM_I/$PKG_NAME-$PKG_VERSION-$pkgrel-$P_ARCH.pkg.tar.gz"
        fi
    done
}

bump_rel() {
    # This function is only used if DRUNK_SKIPBUMP is true
    # Basically bumps pkgrel up by +1 for every pkg that it is used with, check --help for more info
    cd $PKG_PATH

    source PKGBUILD
    bump_rel=$((${pkgrel} + 1 ))
    export srel=$bump_rel
    # Now lets modify out PKGBUILD with new release string
    sed -i "s/pkgrel=${pkgrel}/pkgrel=${bump_rel}/g" PKGBUILD_NEW
}

build_pkg_docker() {
    docker_set_kde_status

    sleep 1

    docker_initial_setup

    for (( p=0; p<${#PKG_LIST[@]}; p++ )); do
    rm -f $DRUNK_TEMP/builds $DRUNK_TEMP/.drunk_locked

    PKG_NAME=$(basename "${PKG_LIST[p]}")
    drunk_debug "List of packages to build: ${PKG_LIST}"

    # --leave-tmp is used here because the pkg's here are looped until every
    # single of them gets built, but as the script ends in docker then it tries to
    # clean the tmp that has our flags give by main script here

    drunk_message "DOCKER: Started compiling package $PKG_NAME"
    docker_user_run_cmd "cd ~/DRUNK && ./drunk --leave-tmp -b ${PKG_NAME}"

    rm -f $DRUNK_TEMP/builds $DRUNK_TEMP/.drunk_locked

    # Reset is needed for containers so they start to build new package without older pkg dependencies
    # Keeps hidden linked deps results lower
    docker_reset

    done

    rm -f $DRUNK_TEMP/.keep_tmp
}
