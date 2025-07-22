##
# Dialog extension for Package Builder (reuses existing shell module)
##

dummy_dialog() {
    echo "Work in Progress... Coming soon!"
    sleep 1
    echo "Loading Dialog Menu..."
    sleep 3
    pkg_dialog_main
}

pkg_dialog_main() {
    # Option text
    OPTION1="Build package/packages"
    OPTION2="Build and clean package/packages"
    OPTION3="Clean package"

    # Dialog parameters
    HEIGHT=30
    WIDTH=80
    CHOICE_HEIGHT=30
    BACKTITLE=""
    TITLE="Developer's friendly UI"
    MENU="Choose one of the following options:"

    OPTIONS=(
        1 "$OPTION1"
        2 "$OPTION2"
        3 "$OPTION3"
    )

    CHOICE=$("$DIALOG_BIN" --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                --erase-on-exit \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

    case $CHOICE in
        1)
            log INFO "Selected: $OPTION1"
            dummy_dialog
            ;;
        2)
            log INFO "Selected: $OPTION2"
            dummy_dialog
            ;;
        3)
            log INFO "Selected: $OPTION3"
            dummy_dialog
            ;;
        *)
            log WARN "Invalid selection in pkg_dialog_main: '$CHOICE'"
            ;;
    esac
}
