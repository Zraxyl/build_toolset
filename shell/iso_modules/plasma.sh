##
# Plasma desktop module
##

rootfs_plasma() {
    message Making rootfs environment with plasma-desktop
    cd $ISO_ROOT/rootfs

    as_root mkdir -pv system

    as_root $STRAP -G system/ ${PLASMA_PKG}
}

# Start from scratch and delete old files
make_plasma_clean_iso () {
    message Making clean iso build with plasma-desktop env

    # Clean everything
    full_clean

    # Prepare proper env
    prepare_env

    # Make LiveOS rootfs
    set +e
    rootfs_plasma

    if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME ]; then
        message Making rootfs crashed so trying again
        # Multiple checks as umount dosent wanna play with us that well for some cases
        rootfs_umount
        rootfs_umount
        rootfs_umount
        # Lets clean and restart the proccess ( loop until done )
        as_root rm -rf $ISO_ROOT/rootfs/system
        sleep 2
        rootfs_plasma
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

    # Enable sddm plymouth
    exec_rootfs systemctl enable sddm-plymouth

    # Clean/Remove old pkg files that bottle has ( reduce iso overall size )
    message Cleaning up old pkg files
    exec_rootfs bottle -Scc --noconfirm
    # + older synced db / cache
    exec_rootfs rm -rf /var/lib/bottle/sync/*

    # Make final squashfs of rootfs
    make_squashfs

    # Finally generate iso
    generate_iso
}
