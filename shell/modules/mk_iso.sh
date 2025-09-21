#
# Lets not use temp here as dev may want to see/edit some specific areas of rootfs
# So lets make new folder called system_iso where we do all the things
#

if [ "${ARCH}" = "aarch64" ]; then
	msg_warning "AArch64 isn't supported yet!!!"
else
	msg_debug Arch is OK
fi

# This will be a list cli ISO variant of functions to run in menu
iso_variant_selector() {
    # Lets remove compile lock as its not useful here
    as_user_del $TOOL_TEMP/.builder_locked

    prepare_iso_env

    HEIGHT=30
    WIDTH=80
    CHOICE_HEIGHT=30

    BACKTITLE="Easy $DISTRO_NAME-iso crator tool"
    TITLE="ISO VARIANT SELECTOR"
    MENU="Select the option you need"

    OPTIONS=(
    1 "Make CLI env ISO"
    2 "Make GUI Installer ISO"
    3 "Exit"
    )

    CHOICE=$(dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "$TITLE" \
    --menu "$MENU" \
    $HEIGHT $WIDTH $CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
    2>&1 >/dev/tty)

    case $CHOICE in
        1) cli_menu_selection ;;
        2) gui_menu_selection ;;
        3) force_clean_tmp && exit ;;
    esac
}

# CLI ISO BUILD DIALOG
cli_menu_selection() {
    HEIGHT=30
    WIDTH=80
    CHOICE_HEIGHT=30

    BACKTITLE="Easy $DISTRO_NAME-iso crator tool"
    TITLE="CLI ISO CREATOR"
    MENU="Select the option you need"

    OPTIONS=(
    1 "Make clean iso ( cleans everything )"
    2 "Make dirty iso with local changes"
    3 "Make iso ( Skip everything and make just iso )"
    4 "Make efi ( needs rootfs )"
    5 "Clean everything"
    6 "Back"
    )

    CHOICE=$(dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "$TITLE" \
    --menu "$MENU" \
    $HEIGHT $WIDTH $CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
    2>&1 >/dev/tty)

    case $CHOICE in
        1) make_cli_clean_iso ;;
        2) make_cli_dirty_iso ;;
        3) generate_iso ;;
        4) make_efi ;;
        5) full_clean ;;
        6) iso_variant_selector ;;
    esac
}

# GUI INSTALLER ISO BUILD DIALOG
gui_menu_selection() {
    HEIGHT=30
    WIDTH=80
    CHOICE_HEIGHT=30

    BACKTITLE="Easy $DISTRO_NAME-iso crator tool"
    TITLE="GUI INSTALLER ISO CREATOR"
    MENU="Select the option you need"

    OPTIONS=(
    1 "Make clean iso ( cleans everything )"
    2 "Make dirty iso with local changes"
    3 "Make iso ( Skip everything and make just iso )"
    4 "Make efi ( needs rootfs )"
    5 "Clean everything"
    6 "Back"
    )

    CHOICE=$(dialog --clear \
    --backtitle "$BACKTITLE" \
    --title "$TITLE" \
    --menu "$MENU" \
    $HEIGHT $WIDTH $CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
    2>&1 >/dev/tty)

    case $CHOICE in
        1) make_plasma_clean_iso ;;
        2) make_plasma_dirty_iso ;;
        3) generate_iso ;;
        4) make_efi ;;
        5) full_clean ;;
        6) iso_variant_selector ;;
    esac
}
