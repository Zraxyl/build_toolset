dialog_main() {
    clear

    HEIGHT=30
    WIDTH=80
    CHOICE_HEIGHT=30
    BACKTITLE=""
    TITLE="Developer's friendly UI"
    MENU="Choose one of the following options:"

    OPTIONS=(
        1 "Package Builder options"
        2 "Build nightly ISO"
    )

    CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

    case $CHOICE in
        1)
            echo "Package Builder options"
            dummy_dialog
        ;;

        2)
            echo "Build nightly ISO"
            dummy_dialog
        ;;
    esac
}

dummy_dialog() {
    clean_tmp

    clear
}
