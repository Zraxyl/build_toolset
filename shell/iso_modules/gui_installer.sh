##
# Plasma desktop module
##

rootfs_plasma() {
    message Making rootfs environment with plasma-desktop
    cd $ISO_ROOT/rootfs

    as_root mkdir -pv system

    as_root $STRAP -G system/ ${INSTALLER_PKG}
}

clean_plasma_rootfs() {
    message Cleaning rootfs from un-needed binaries

    set +e

    # Now clean up some firmware files that wont be needed for installation in x86_64 env
    as_root_del $ISO_ROOT/rootfs/system/lib/firmware/{netronome,qcom,mellanox,qca}

    # Same for other things
    as_root_del $ISO_ROOT/rootfs/system/var/cache/bottle/pkg/*
    as_root_del $ISO_ROOT/rootfs/system/include/
    as_root_del $ISO_ROOT/rootfs/system/usr/include
    as_root_del $ISO_ROOT/rootfs/system/usr/scr
    as_root_del $ISO_ROOT/rootfs/system/usr/libexec/gcc
    as_root_del $ISO_ROOT/rootfs/system/usr/lib*/lib*.a
    as_root_del $ISO_ROOT/rootfs/system/usr/lib*/lib*.la
    as_root_del $ISO_ROOT/rootfs/system/usr/lib*/*/lib*.a
    as_root_del $ISO_ROOT/rootfs/system/usr/lib*/*/lib*.la
    as_root_del $ISO_ROOT/rootfs/system/usr/lib/lib*.a

    # Firmware
    as_root mv $ISO_ROOT/rootfs/system/lib/firmware/{amd,amdgpu,nvidia} $ISO_ROOT/rootfs/system
    as_root_del $ISO_ROOT/rootfs/system/lib/firmware/*
    as_root mv $ISO_ROOT/rootfs/system/{amd,amdgpu,nvidia} $ISO_ROOT/rootfs/system/lib/firmware/

    # strip
    as_root strip --strip-unneeded $ISO_ROOT/rootfs/system/usr/bin/* &> /dev/null
    as_root strip --strip-unneeded $ISO_ROOT/rootfs/system/usr/lib*/*.so &> /dev/null

    set -e
}

# Generate rootfs for squashfs
make_gui_rootfs() {
    message Making rootfs environment
    cd $ISO_ROOT/rootfs

    as_root mkdir -pv system

    as_root $STRAP -G system/ ${CLI_PKG}

    clean_plasma_rootfs
}

# Start from scratch and delete old files
make_plasma_clean_iso () {
    message Making clean iso build with plasma-desktop env

    # Clean everything
    full_clean

    # Prepare proper env
    prepare_iso_env

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
        as_root_del $ISO_ROOT/rootfs/system
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

    # Install packages needed for gui env + installer
    make_gui_rootfs

    # Default changes
    rootfs_defaults

    # Enable sddm plymouth
    exec_rootfs systemctl enable sddm-plymouth

    # Clean/Remove old pkg files that bottle has ( reduce iso overall size )
    message Cleaning up old pkg files
    exec_rootfs bottle -Scc --noconfirm

    # clean older synced db / cache
    exec_rootfs rm -rf /var/lib/bottle/sync/*

    # Make final squashfs of rootfs
    make_iso_squashfs

    # Finally generate iso
    generate_iso
}

installer_defaults() {
    # Autostart
    as_root mkdir -p $ISO_ROOT/rootfs/system/home/${DISTRO_NAME}/.config/autostart
    as_root chmod -R 777 $ISO_ROOT/rootfs/system/home/${DISTRO_NAME}/.config
    as_root cp $ISO_ROOT/rootfs/system/usr/share/applications/org.kde.konsole.desktop $ISO_ROOT/rootfs/system/home/${DISTRO_NAME}/.config/autostart/

    # Theme
    # exec_rootfs lookandfeeltool -a org.kde.breezedark
}

# Start from scratch and delete old files
make_cli_dirty_iso () {
    message Making dirty iso build

    # Prepare proper env
    prepare_iso_env

    # Check if we need to re-make the rootfs
    if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME ]; then
        set +e
        make_gui_rootfs
        set -e
        if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME ]; then
            # Multiple checks as umount dosent wanna play with us that well for some cases
            rootfs_umount
            rootfs_umount
            rootfs_umount
            # Lets clean and restart the proccess ( loop until done )
            as_root_del $ISO_ROOT/rootfs/system

            make_gui_rootfs
        fi
    fi

    # Make efi image for iso to use later on
    make_efi

    rootfs_plasma

    # Run default changes for LiveOS
    rootfs_defaults

    # Clean the rootfs
    clean_plasma_rootfs

    # Installer defaults
    installer_defaults

    # Make base iso filesystems
    make_base_iso

    # Make final squashfs of rootfs
    make_iso_squashfs

    # Finally generate iso
    generate_iso
}
