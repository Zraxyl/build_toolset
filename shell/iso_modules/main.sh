##
# Main module
##

# sudo wrapper
as_root() {
    sudo "$@"
}

exec_rootfs() {
    as_root chroot $ISO_ROOT/rootfs/system "$@"
}

# Clean and force remove everything
full_clean() {
    message Cleaning up before starting new build

    # Check atleast 3 times before returning to deleting things
    rootfs_umount
    rootfs_umount
    rootfs_umount

    as_root rm -rf $ISO_ROOT
}

rootfs_umount() {
    if [ -f $ISO_ROOT/rootfs/system/sys/ ]; then
        message Unmounting $ISO_ROOT/rootfs/system/sys/
        as_root umount -f -l $ISO_ROOT/rootfs/system/sys
        sleep 4
    fi

    if [ -f $ISO_ROOT/rootfs/system/proc/ ]; then
        message Unmounting $ISO_ROOT/rootfs/system/proc/
        as_root umount -f -l $ISO_ROOT/rootfs/system/proc
        sleep 4
    fi

    if [ -f $ISO_ROOT/rootfs/system/dev/ ]; then
        message Unmounting $ISO_ROOT/rootfs/system/dev/
        as_root umount -f -l $ISO_ROOT/rootfs/system/dev
        sleep 4
    fi
}

# Make base structure of iso
prepare_env() {
    mkdir -p $ISO_ROOT/{iso,efi/mnt,rootfs}
}

# Make final iso image ( bios + uefi compatible )
generate_iso() {
    message Creating bootable iso image

    as_root rm -f $P_ROOT/$DISTRO_NAME.iso

    as_root xorriso -as mkisofs \
    -r -V "installer" \
    -J -J -joliet-long -cache-inodes \
    -b syslinux/isolinux.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table\
    -eltorito-alt-boot -eltorito-platform efi -eltorito-boot \
    kernel/efi.img -no-emul-boot \
    -o $P_ROOT/$DISTRO_NAME.iso $ISO_ROOT/iso/

    message Iso image is located now at $P_ROOT/$DISTRO_NAME.iso
}

# Make efi image for iso to use ( SD-Boot )
make_efi() {
    cd $ISO_ROOT/efi

    pwd

    export TOOL_LOOP=$(as_root losetup -f)
    msg_debug Found and using this loop $TOOL_LOOP

    # Create blank image
    msg_debug Creating new and blank efi image
    as_root dd if=/dev/zero of=efi.img bs=1 count=0 seek=64M

    # Add out image to /dev/loop
    as_root losetup -P $TOOL_LOOP efi.img

    # Make sure to format the image before mounting it ( wont mount if no partitions )
    as_root mkfs.vfat $TOOL_LOOP

    # Mount image to its mnt
    as_root mount ${TOOL_LOOP} mnt/

    sleep 2

    # Copy over vmlinuz from rootfs
    as_root cp -fv $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME mnt/

    # Install EFI binaries
    as_root mkdir -pv mnt/EFI/{BOOT,systemd}
    as_root cp -fv /usr/lib/systemd/boot/efi/systemd-bootx64.efi mnt/EFI/BOOT/BOOTX64.EFI
    as_root cp -fv /usr/lib/systemd/boot/efi/systemd-bootx64.efi mnt/EFI/systemd/systemd-bootx64.efi

    # Copy over default laoder configs
    as_root cp -rfv $P_ROOT/build/toolset/iso/loader mnt/

    as_root chown -R root mnt/

    # make initrd for efi image
    kver=$(as_root basename $ISO_ROOT/rootfs/system/lib/modules/6.*)
    as_root dracut --kver $kver -m "base lvm kernel-modules" -a "dmsquash-live" --add-drivers squashfs --filesystems "squashfs ext4 ext3" mnt/initrd.img --force

    sleep 2 && sync

    as_root losetup -d $TOOL_LOOP

    as_root chown -R $TOOL_USER efi.img

    # Now copy over our efi image amd initrd image for legacy users
    as_root mkdir -p $ISO_ROOT/iso/kernel/
    as_root cp -fv efi.img $ISO_ROOT/iso/kernel/efi.img

    as_root cp -rv mnt/initrd.img $ISO_ROOT/iso/kernel/initrd.img

    # Again triple umount as umount likes to give a finger
    as_root umount -f -l mnt/
    sleep 2 && sync
}

# Basic iso env with syslinux in place
make_base_iso() {
    message Making iso base filesystem
    cd $ISO_ROOT/iso

    mkdir -pv syslinux

    # Copy over bios dependent files form syslinux
    cp -fv /usr/share/syslinux/{isolinux.bin,{ldlinux,libcom32,libmenu,libutil,linux,menu,vesa,vesainfo,vesamenu,whichsys}.c32} syslinux/
    cp -fv $P_ROOT/build/toolset/iso/isolinux.cfg syslinux/

    # make other dir's
    mkdir -pv LiveOS kernel

    as_root cp -fv $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME $ISO_ROOT/iso/kernel/vmlinuz
    as_root ls -la $ISO_ROOT/iso/kernel/
}

# Generate rootfs for squashfs
make_rootfs() {
    message Making rootfs environment
    cd $ISO_ROOT/rootfs

    as_root mkdir -pv system

    as_root $STRAP -G system/ ${CLI_PKG}

    # Now clean up some firmware files that wont be needed for installation in x86_64 env
    as_root rm -rf system/lib/firmware/{netronome,qcom,mellanox,qca}
}

# Here we add things to the rootfs such as passwd and etc
# Even if these defaults have been applied earlier we still wanna redo all of this in case of changes to this function if possible
# Basically allow errors here
rootfs_defaults() {
    set +e
    message Adding changes to rootfs
    msg_warning Errors are allowed in rootfs changes

    # Lets make encrypted string of password for root and non-root user
    # https://askubuntu.com/a/80447
    export ROOT_PASSWORD=$(echo toor | openssl passwd -1 -stdin)
    export NON_ROOT_PASSWORD=$(echo $DISTRO_NAME | openssl passwd -1 -stdin)

    message Creating non-root user
    # Lets add non-root user ( with home dir + add to wheel + adm groups )
    exec_rootfs useradd -m -G wheel,adm $DISTRO_NAME

    message Setting root and non-root user password
    # Lets set password for root and non-root
    exec_rootfs usermod --password $ROOT_PASSWORD root
    exec_rootfs usermod --password $NON_ROOT_PASSWORD $DISTRO_NAME

    message Copying over bashrc for root user
    # Now copy over bashrc for root user
    exec_rootfs cp -f /etc/bash.bashrc /root/.bashrc

    message Enabling systemd default services
    exec_rootfs systemctl enable dhcpcd

    exec_rootfs systemctl enable getty@tty2

    # Some possible errors may occure with these in some systems
    exec_rootfs systemctl disable nghttpx
    exec_rootfs systemctl disable systemd-networkd-wait-online.service
    exec_rootfs systemctl mask systemd-networkd-wait-online.service
    set -e
}

# Generate squashfs for LiveOS
make_squashfs() {
    # Even for dirty we will remake the squashfs as of possible intended changes
    message Making final LiveOS squashfs from rootfs
    rm -f $ISO_ROOT/iso/LiveOS/squashfs.img

    as_root mksquashfs $ISO_ROOT/rootfs/system $ISO_ROOT/iso/LiveOS/squashfs.img -wildcards -e 'dev/*' -e 'proc/*' -e 'sys/*'
}

# Start from scratch and delete old files
make_dirty_iso () {
    message Making dirty iso build

    # Prepare proper env
    prepare_env

    # Check if we need to re-make the rootfs
    if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME ]; then
        set +e
        make_rootfs
        set -e
        if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME ]; then
            # Multiple checks as umount dosent wanna play with us that well for some cases
            rootfs_umount
            rootfs_umount
            rootfs_umount
            # Lets clean and restart the proccess ( loop until done )
            as_root rm -rf $ISO_ROOT/rootfs/system

            make_rootfs
        fi
    fi

    # Make efi image for iso to use later on
    make_efi

    # Make base iso filesystems
    make_base_iso

    # Add default rootfs changes on the Fly
    rootfs_defaults

    # Make final squashfs of rootfs
    make_squashfs

    # Finally generate iso
    generate_iso
}

# Start from scratch and delete old files
make_clean_iso () {
    message Making clean iso build

    # Clean everything
    full_clean

    # Prepare proper env
    prepare_env

    # Make LiveOS rootfs
    set +e
    make_rootfs

    if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-$DISTRO_NAME ]; then
        message Making rootfs crashed so trying again
        # Multiple checks as umount dosent wanna play with us that well for some cases
        rootfs_umount
        rootfs_umount
        rootfs_umount
        # Lets clean and restart the proccess ( loop until done )
        as_root rm -rf $ISO_ROOT/rootfs/system
        sleep 2
        make_rootfs
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
    make_squashfs

    # Finally generate iso
    generate_iso
}
