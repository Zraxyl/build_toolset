#
# Lets not use temp here as dev may want to see/edit some specific areas of rootfs
# So lets make new folder called drunk_iso where we do all the things
#

if [ "${ARCH}" = "aarch64" ]; then
	clean_tmp
	drunk_err "AArch64 isn't supported yet!!!"
else
	drunk_debug Arch is OK
fi

# This will be a list of functions to run in menu
menu_selection() {
    # Lets remove compile lock as its not useful here
    rm -f $P_ROOT/tools/tmp/.drunk_locked

    prepare_env

    HEIGHT=30
    WIDTH=80
    CHOICE_HEIGHT=30

    BACKTITLE="Easy drunk-iso crator tool"
    TITLE="ISO CREATOR"
    MENU="Select the option you need"

    OPTIONS=(
    1 "Make clean iso ( cleans everything )"
    2 "Make dirty iso with local changes"
    3 "Make iso ( Skip everything and make just iso )"
    4 "Make efi ( needs rootfs )"
    5 "Clean everything"
    )

    CHOICE=$(dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "$TITLE" \
    --menu "$MENU" \
    $HEIGHT $WIDTH $CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
    2>&1 >/dev/tty)

    clear

    case $CHOICE in
        1) make_clean_iso ;;
        2) make_dirty_iso ;;
        3) generate_iso ;;
        4) make_efi ;;
        5) full_clean ;;
    esac
}

# sudo wrapper
as_root() {
    sudo "$@"
}

exec_rootfs() {
    as_root chroot $ISO_ROOT/rootfs/system "$@"
}

# Clean and force remove everything
full_clean() {
    drunk_message Cleaning up before starting new build

    # Check atleast 3 times before returning to deleting things
    rootfs_umount
    rootfs_umount
    rootfs_umount

    as_root rm -rf $ISO_ROOT
}

rootfs_umount() {
    if [ -f $ISO_ROOT/rootfs/system/sys/ ]; then
        drunk_message Unmounting $ISO_ROOT/rootfs/system/sys/
        as_root umount -f -l $ISO_ROOT/rootfs/system/sys
        sleep 4
    fi

    if [ -f $ISO_ROOT/rootfs/system/proc/ ]; then
        drunk_message Unmounting $ISO_ROOT/rootfs/system/proc/
        as_root umount -f -l $ISO_ROOT/rootfs/system/proc
        sleep 4
    fi

    if [ -f $ISO_ROOT/rootfs/system/dev/ ]; then
        drunk_message Unmounting $ISO_ROOT/rootfs/system/dev/
        as_root umount -f -l $ISO_ROOT/rootfs/system/dev
        sleep 4
    fi
}

# Start from scratch and delete old files
make_dirty_iso () {
    drunk_message Making dirty iso build

    # Prepare proper env
    prepare_env

    # Check if we need to re-make the rootfs
    if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-drunk ]; then
        set +e
        make_rootfs
        set -e
        if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-drunk ]; then
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
    drunk_message Making clean iso build

    # Clean everything
    full_clean

    # Prepare proper env
    prepare_env

    # Make LiveOS rootfs
    set +e
    make_rootfs

    if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-drunk ]; then
        drunk_message Making rootfs crashed so trying again
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

# Start from scratch and delete old files
make_plasma_clean_iso () {
    drunk_message Making clean iso build with plasma-desktop env

    # Clean everything
    full_clean

    # Prepare proper env
    prepare_env

    # Make LiveOS rootfs
    set +e
    rootfs_plasma

    if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-drunk ]; then
        drunk_message Making rootfs crashed so trying again
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
    drunk_message Cleaning up old pkg files
    exec_rootfs bottle -Scc --noconfirm
    # + older synced db / cache
    exec_rootfs rm -rf /var/lib/bottle/sync/*

    # Make final squashfs of rootfs
    make_squashfs

    # Finally generate iso
    generate_iso
}

make_xfce_clean_iso () {
    drunk_message Making clean iso build with xfce-desktop env

    # Clean everything
    full_clean

    # Prepare proper env
    prepare_env

    # Make LiveOS rootfs
    set +e
    rootfs_xfce

    if [ ! -f $ISO_ROOT/rootfs/system/boot/vmlinuz-drunk ]; then
        drunk_message Making rootfs crashed so trying again
        # Multiple checks as umount dosent wanna play with us that well for some cases
        rootfs_umount
        rootfs_umount
        rootfs_umount
        # Lets clean and restart the proccess ( loop until done )
        as_root rm -rf $ISO_ROOT/rootfs/system
        sleep 2
        rootfs_xfce
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
    exec_rootfs systemctl enable lightdm

    # Clean/Remove old pkg files that bottle has ( reduce iso overall size )
    drunk_message Cleaning up old pkg files
    exec_rootfs bottle -Scc --noconfirm
    # + older synced db / cache
    exec_rootfs rm -rf /var/lib/bottle/sync/*

    # Make final squashfs of rootfs
    make_squashfs

    # Finally generate iso
    generate_iso
}

# Make base structure of iso
prepare_env() {
    mkdir -p $ISO_ROOT/{iso,efi/mnt,rootfs}
}

# Make efi image for iso to use ( SD-Boot )
make_efi() {
    cd $ISO_ROOT/efi

    pwd

    DRUNK_LOOP=$(as_root losetup -f)
    drunk_debug Found and using this loop $DRUNK_LOOP

    # Create blank image
    drunk_debug Creating new and blank efi image
    as_root dd if=/dev/zero of=efi.img bs=1 count=0 seek=64M

    # Add out image to /dev/loop
    as_root losetup -P $DRUNK_LOOP efi.img

    # Make sure to format the image before mounting it ( wont mount if no partitions )
    as_root mkfs.vfat $DRUNK_LOOP

    # Mount image to its mnt
    as_root mount ${DRUNK_LOOP} mnt/

    sleep 2

    # Copy over vmlinuz from rootfs
    as_root cp -fv $ISO_ROOT/rootfs/system/boot/vmlinuz-drunk mnt/

    # Install EFI binaries
    as_root mkdir -pv mnt/EFI/{BOOT,systemd}
    as_root cp -fv /usr/lib/systemd/boot/efi/systemd-bootx64.efi mnt/EFI/BOOT/BOOTX64.EFI
    as_root cp -fv /usr/lib/systemd/boot/efi/systemd-bootx64.efi mnt/EFI/systemd/systemd-bootx64.efi

    # Copy over default laoder configs
    as_root cp -rfv $P_ROOT/tools/iso/loader mnt/

    as_root chown -R root mnt/

    # make initrd for efi image
    kver=$(as_root basename $ISO_ROOT/rootfs/system/lib/modules/6.*)
    as_root dracut --kver $kver -m "base lvm kernel-modules" -a "dmsquash-live" --add-drivers squashfs --filesystems "squashfs ext4 ext3" mnt/drunk-init.img --force

    sleep 2 && sync

    as_root losetup -d $DRUNK_LOOP

    as_root chown -R $DRUNK_USER efi.img

    # Now copy over our efi image amd initrd image for legacy users
    as_root mkdir -p $ISO_ROOT/iso/kernel/
    as_root cp -fv efi.img $ISO_ROOT/iso/kernel/efi.img

    as_root cp -rv mnt/drunk-init.img $ISO_ROOT/iso/kernel/drunk-init.img

    # Again triple umount as umount likes to give a finger
    as_root umount -f -l mnt/
    sleep 2 && sync
}

# Basic iso env with syslinux in place
make_base_iso() {
    drunk_message Making iso base filesystem
    cd $ISO_ROOT/iso

    mkdir -pv syslinux

    # Copy over bios dependent files form syslinux
    cp -fv /usr/share/syslinux/{isolinux.bin,{ldlinux,libcom32,libmenu,libutil,linux,menu,vesa,vesainfo,vesamenu,whichsys}.c32} syslinux/
    cp -fv $P_ROOT/tools/iso/isolinux.cfg syslinux/

    # make other dir's
    mkdir -pv LiveOS kernel

    as_root cp -fv $ISO_ROOT/rootfs/system/boot/vmlinuz-drunk $ISO_ROOT/iso/kernel/
}

# Generate rootfs for squashfs
make_rootfs() {
    drunk_message Making rootfs environment
    cd $ISO_ROOT/rootfs

    as_root mkdir -pv system

    as_root bottle-strap -G system/ base-drunk nano wireless-tools drunk-install-scripts sudo parted libmd
}

# Here we add things to the rootfs such as passwd and etc
# Even if these defaults have been applied earlier we still wanna redo all of this in case of changes to this function if possible
# Basically allow errors here
rootfs_defaults() {
    set +e
    drunk_message Adding changes to rootfs
    drunk_warn Errors are allowed in rootfs changes

    # Lets make encrypted string of password for root and drunk user
    # https://askubuntu.com/a/80447
    DRUNK_ROOT_PASSWORD=$(echo toor | openssl passwd -1 -stdin)
    DRUNK_DRUNK_PASSWORD=$(echo drunk | openssl passwd -1 -stdin)

    drunk_message Creating drunk user
    # Lets add drunk user ( with home dir + add to wheel + adm groups )
    exec_rootfs useradd -m -G wheel,adm drunk

    drunk_message Setting root and drunk user password
    # Lets set password for root and drunk
    exec_rootfs usermod --password $DRUNK_ROOT_PASSWORD root
    exec_rootfs usermod --password $DRUNK_DRUNK_PASSWORD drunk

    drunk_message Copying over bashrc for root user
    # Now copy over bashrc for root user
    exec_rootfs cp -f /etc/bash.bashrc /root/.bashrc

    drunk_message Enabling systemd default services
    exec_rootfs systemctl enable dhcpcd

    exec_rootfs systemctl enable getty@tty2

    # Some possible errors may occure with these in some systems
    exec_rootfs systemctl disable nghttpx
    exec_rootfs systemctl disable systemd-networkd-wait-online.service
    exec_rootfs systemctl mask systemd-networkd-wait-online.service
    set -e
}

rootfs_plasma() {
    drunk_message Making rootfs environment with plasma-desktop
    cd $ISO_ROOT/rootfs

    as_root mkdir -pv system

    as_root bottle-strap -G system/ base-drunk nano wireless-tools drunk-install-scripts sudo parted libmd drunk-desktop-plasma-clean
}

rootfs_xfce() {
    drunk_message Making rootfs environment with xfce-desktop
    cd $ISO_ROOT/rootfs

    as_root mkdir -pv system

    as_root bottle-strap -G system/ base-drunk nano wireless-tools drunk-install-scripts sudo parted libmd drunk-desktop-xfce-clean lightdm
}

# Generate squashfs for LiveOS
make_squashfs() {
    # Even for dirty we will remake the squashfs as of possible intended changes
    drunk_message Making final LiveOS squashfs from rootfs
    rm -f $ISO_ROOT/iso/LiveOS/squashfs.img

    as_root mksquashfs $ISO_ROOT/rootfs/system $ISO_ROOT/iso/LiveOS/squashfs.img -wildcards -e 'dev/*' -e 'proc/*' -e 'sys/*'
}

# Make final iso image ( bios + uefi compatible )
generate_iso() {
    drunk_message Creating bootable iso image

    as_root rm -f $P_ROOT/drunk.iso

    as_root xorriso -as mkisofs \
    -r -V "installer" \
    -J -J -joliet-long -cache-inodes \
    -b syslinux/isolinux.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table\
    -eltorito-alt-boot -eltorito-platform efi -eltorito-boot \
    kernel/efi.img -no-emul-boot \
    -o $P_ROOT/drunk.iso $ISO_ROOT/iso/

    drunk_message Iso image is located now at $P_ROOT/drunk.iso
}
