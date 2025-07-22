#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="build_toolset.log"

declare -A ERROR_DB=(
  [100]="dialog utility not found. Please install 'dialog'.|Install the dialog package for your distribution."
  [101]=".env and .env.template missing.|Provide a .env.template file in the project root."
  [102]="Unknown or invalid command: %s|Use --help to see available commands and required order."
  [103]="Failed to copy .env.template to .env.|Check file permissions."
  [104]="Cannot load modules before environment is set up.|You must run: $0 --env FIRST."
  [105]="Operation cancelled by user.|No action taken."
  [106]="You must specify commands in proper order: --env before --modules before --init before --dialog.|Correct example: $0 --env --modules --init --dialog"
  [200]="Submodule install script failed: %s|Check the install.sh script in the affected module."
)

log() {
  local level="$1"; shift
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$LOG_FILE"
}

err() {
  local code="$1"; shift
  local msg hint
  IFS="|" read -r msg hint <<< "${ERROR_DB[$code]:-Unknown error.}"
  msg="${msg//%s/$1}"; shift || true
  echo -e "\e[31m[ERROR]\e[0m (E$code) $msg" >&2
  [[ -n "$hint" ]] && echo -e "\e[33m[HINT]\e[0m  $hint" >&2
  log "ERROR" "Code=$code $msg"
  [[ -n "$hint" ]] && log "ERROR" "Hint: $hint"
  exit "$code"
}

info()    { echo -e "\e[34m[INFO]\e[0m $*"; log "INFO" "$*"; }
success() { echo -e "\e[32m[SUCCESS]\e[0m $*"; log "SUCCESS" "$*"; }

usage() {
  cat <<EOF
Unified Build Toolset

Usage: $(basename "$0") [COMMANDS or --flags]

STRICT ORDER REQUIRED (super-sequences allowed):
  --env       Setup .env, make script executable, AND create legacy symlinks
  --modules   Load or update module dependencies (requires --env first)
  --init      Initial setup (env + modules)
  --dialog    Launch interactive menu (TUI)
  --help      Show this help message

Examples:
  $0 --env --modules --init --dialog
  $0 --env --modules
  $0 --env
  $0 --dialog
EOF
  log "INFO" "Displayed usage"
}

check_env_present() {
  if [[ -f .env ]]; then
    log "DEBUG" ".env present"
    return 0
  else
    log "DEBUG" ".env missing"
    return 1
  fi
}

bootstrap_legacy_links() {
  info "Creating legacy symlinks..."
  for script in envsetup load_modules initial_setup dialog; do
    local target="tools/${script}.sh"
    if [[ -f "$target" ]]; then
      ln -sf "$target" "$script"
      log "INFO" "Symlinked $script → $target"
    else
      log "WARN" "Missing $target; skipping symlink"
    fi
  done
  success "Legacy symlinks created."
}

setup_env() {
  log "INFO" "Starting environment setup"
  info "Checking for .env file..."
  if [[ ! -f .env ]]; then
    if [[ -f .env.template ]]; then
      read -p "No .env found. Create from template? [y/N]: " ans
      log "DEBUG" "User answered: $ans"
      if [[ "$ans" =~ ^[Yy]$ ]]; then
        cp .env.template .env || err 103
        success ".env created from template."
      else
        info ".env not created."
        err 105
      fi
    else
      err 101
    fi
  else
    success ".env already present."
  fi

  # Ensure main script is executable
  chmod +x build_toolset.sh
  info "Ensured build_toolset.sh is executable."

  # Create legacy symlinks
  bootstrap_legacy_links
}

initial_setup() {
  log "INFO" "Running initial setup"
  info "Running initial setup (env + modules)..."
  [[ -z "${RUN_ONCE_ENV:-}" ]]     && { setup_env;     RUN_ONCE_ENV=1; }
  [[ -z "${RUN_ONCE_MODULES:-}" ]] && { load_modules; RUN_ONCE_MODULES=1; }
  success "Initial setup complete."
}

load_modules() {
  log "INFO" "Running load_modules"
  ! check_env_present && err 104
  info "Updating git submodules..."
  git submodule update --init --recursive
  local failed=0
  for module in modules/*/install.sh; do
    if [[ -f "$module" ]]; then
      info "Executing $module"
      log "INFO" "Running installer: $module"
      bash "$module" || err 200 "$module"
    fi
  done
  success "Module loading complete."
}

run_dialog_menu() {
  log "INFO" "Launching TUI menu"
  command -v dialog >/dev/null 2>&1 || err 100

  while true; do
    local opts=(1 "Initial Setup" 2 "Load Modules" 3 "Env Setup" 4 "Exit")
    [[ ! -f .env ]] && opts[3]="Load Modules [disabled]"

    local choice
    choice=$(dialog --backtitle "Build Toolset" --title "Main Menu" \
      --menu "Choose an action:" 15 60 6 "${opts[@]}" 3>&1 1>&2 2>&3) || break
    clear

    case "$choice" in
      1) initial_setup ;;
      2) check_env_present && load_modules || dialog --msgbox "Run Env Setup first." 7 40 ;;
      3) setup_env ;;
      4) break ;;
      *) err 102 "$choice" ;;
    esac

    read -p "Press Enter to continue..." _
  done
}

main() {
  log "INFO" "Invoked with args: $*"
  [[ $# -eq 0 ]] && usage && exit 0

  local norm=()
  for arg in "$@"; do
    case "$arg" in
      --env|env)        norm+=("env") ;;
      --modules|modules)norm+=("modules") ;;
      --init|init)      norm+=("init") ;;
      --dialog|dialog)  norm+=("dialog") ;;
      --help|help|-h)   usage; exit 0 ;;
      *)                err 102 "$arg" ;;
    esac
  done

  # Deduplicate and enforce order env→modules→init→dialog
  local seen_env=0 seen_mod=0 seen_init=0
  local cmds=()
  for arg in "${norm[@]}"; do
    case "$arg" in
      env)      (( seen_env++ == 0 )) && cmds+=("env") ;;
      modules)  (( seen_mod++ == 0 )) && cmds+=("modules") ;;
      init)     (( seen_init++ == 0 )) && cmds+=("init") ;;
      dialog)                cmds+=("dialog") ;;
    esac
  done

  # Validate monotonic sequence
  local order="env modules init dialog"
  local last=0
  for cmd in "${cmds[@]}"; do
    local idx=$(echo "$order" | tr ' ' '\n' | grep -nx "^$cmd$" | cut -d: -f1)
    (( idx >= last )) || err 106
    last=$idx
  done

  for cmd in "${cmds[@]}"; do
    log "INFO" "Executing: $cmd"
    case "$cmd" in
      env)      setup_env ;;
      modules)  load_modules ;;
      init)     initial_setup ;;
      dialog)   run_dialog_menu ;;
    esac
  done

  log "INFO" "All requested commands complete"
}

main "$@"
