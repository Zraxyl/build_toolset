#
# Lets not use temp here as dev may want to see/edit some specific areas of rootfs
# So lets make new folder called system_iso where we do all the things
#

if [ "${ARCH}" = "aarch64" ]; then
	clean_tmp
	msg_error "AArch64 isn't supported yet!!!"
else
	msg_debug Arch is OK
fi

# Load modules for iso creator
source $P_ROOT/build/toolset/shell/iso_modules/main.sh
echo "[ LOADED ]: Main functions iso"

# Load modules for iso creator
source $P_ROOT/build/toolset/shell/iso_modules/xfce.sh
echo "[ LOADED ]: XFCE module"

# Load modules for iso creator
source $P_ROOT/build/toolset/shell/iso_modules/plasma.sh
echo "[ LOADED ]: Plasma module"

# This will be a list of functions to run in menu
menu_selection() {
    # Lets remove compile lock as its not useful here
    rm -f $TOOL_TEMP/.builder_locked

    prepare_env

    HEIGHT=30
    WIDTH=80
    CHOICE_HEIGHT=30

    BACKTITLE="Easy $DISTRO_NAME-iso crator tool"
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
