##
# dialog-manager.sh
# Exports, preflight checks, static menu with two options, structured logging
##

set -euo pipefail
IFS=$'\n\t'

########################################
# 1. Configuration & Environment Exports
########################################

# Ensure P_ROOT is defined (set this before invoking the script)
: "${P_ROOT:?ERROR: P_ROOT must be set to your project root before running dialog-manager.sh}"

# Base directory for dialog assets
export D_ROOT="${P_ROOT}/build/toolset/dialog"
export D_MODULES_DIR="${D_ROOT}/modules"
export D_TMP_DIR="${D_ROOT}/tmp"

# Path to the `dialog` binary (override if non‑standard)
export DIALOG_BIN="${DIALOG_BIN:-/usr/bin/dialog}"

########################################
# 2. Pre‑flight Dependency Checks
########################################

preflight() {
  command -v "$DIALOG_BIN" >/dev/null 2>&1 \
    || { echo "ERROR: 'dialog' not found at $DIALOG_BIN"; exit 1; }
  [[ -d "$D_MODULES_DIR" ]] \
    || { echo "ERROR: Modules directory '$D_MODULES_DIR' is missing"; exit 1; }
  mkdir -p "$D_TMP_DIR"
}
preflight

########################################
# 3. Structured Logging & Cleanup
########################################

log() {
  local lvl=$1; shift
  printf '[%s] [%s] %s\n' "$(date +'%Y-%m-%dT%H:%M:%S%z')" "$lvl" "$*"
}

cleanup() {
  log INFO "Cleaning up temporary state in $D_TMP_DIR"
  rm -rf "$D_TMP_DIR"/* || true
}
trap cleanup EXIT

########################################
# 4. Load Dialog Modules
########################################

if [[ -d "$D_MODULES_DIR" ]]; then
  for module in "$D_MODULES_DIR"/*.sh; do
    # shellcheck source=/dev/null
    source "$module"
  done
else
  log WARN "No modules found in $D_MODULES_DIR"
fi

########################################
# 5. Static Dialog Menu
########################################

dialog_menu() {
    # Option text
    OPTION1="Package Builder options"
    OPTION2="Build ISO"

    # Main function
    HEIGHT=30
    WIDTH=80
    CHOICE_HEIGHT=30
    BACKTITLE=""
    TITLE="Developer's friendly UI"
    MENU="Choose one of the following options:"

    OPTIONS=(
        1 "${OPTION1}"
        2 "${OPTION2}"
    )

    CHOICE=$("$DIALOG_BIN" --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT" \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

    case $CHOICE in
        1)
            log INFO "Selected: ${OPTION1}"
            pkg_dialog_main
            ;;
        2)
            log INFO "Selected: ${OPTION2}"
            dummy_dialog
            ;;
        *)
            log WARN "Invalid selection: '$CHOICE'"
            ;;
    esac
}

########################################
# 6. Entry Point
########################################

dialog_main() {
  clear
  dialog_menu
  cleanup
  clear
}

dialog_main
