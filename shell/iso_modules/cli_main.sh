##
# Main module
##

# Generate rootfs for squashfs
make_cli_rootfs() {
    message Making rootfs environment
    cd $ISO_ROOT/rootfs

    as_root mkdir -pv system

    as_root $STRAP -G system/ ${CLI_PKG}

    # Now clean up some firmware files that wont be needed for installation in x86_64 env
    as_root rm -rf $ISO_ROOT/rootfs/system/lib/firmware/{netronome,qcom,mellanox,qca}
}

# Start from scratch and delete old files
make_cli_dirty_iso () {
    message Making dirty iso build

    # Prepare proper env
    prepare_iso_env

    # Check if we need to re-make the rootfs
    if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME ]; then
        set +e
        make_cli_rootfs
        set -e
        if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME ]; then
            # Multiple checks as umount dosent wanna play with us that well for some cases
            rootfs_umount
            rootfs_umount
            rootfs_umount
            # Lets clean and restart the proccess ( loop until done )
            as_root rm -rf $ISO_ROOT/rootfs/system

            make_cli_rootfs
        fi
    fi

    # Make efi image for iso to use later on
    make_efi

    # Make base iso filesystems
    make_base_iso

    # Add default rootfs changes on the Fly
    rootfs_defaults

    # Make final squashfs of rootfs
    make_iso_squashfs

    # Finally generate iso
    generate_iso
}

# Start from scratch and delete old files
make_cli_clean_iso () {
    message Making clean iso build

    # Clean everything
    full_clean

    # Prepare proper env
    prepare_iso_env

    # Make LiveOS rootfs
    set +e
    make_cli_rootfs

    if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME ]; then
        message Making rootfs crashed so trying again
        # Multiple checks as umount dosent wanna play with us that well for some cases
        rootfs_umount
        rootfs_umount
        rootfs_umount
        # Lets clean and restart the proccess ( loop until done )
        as_root rm -rf $ISO_ROOT/rootfs/system
        sleep 2
        make_cli_rootfs
    fi
    set -e

    # Make efi image for iso to use later on
    set +e
    make_efi
    set -e

    # Make base iso filesystems
    make_base_iso

    # Default changes
    rootfs_defaults

    # Make final squashfs of rootfs
    make_iso_squashfs

    # Finally generate iso
    generate_iso
}
