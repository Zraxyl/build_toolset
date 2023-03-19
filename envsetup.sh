#!/bin/bash

set -e -o pipefail -u

##
#   Export some needed things for head script to work with
##

# Dont allow to run this script in other places than specified symlink dir ( So no unknown issues occure )
if [ -f tools/envsetup.sh ];then
    cd "$(dirname "$0")"
else
    echo "Dont run this in other places than its symlink root dir ( Only in a project root dir that has folder called setup )!!!"
    exit 1
fi

export P_ROOT=$(pwd)

##
#   Load modules
##

# Export all variables so bash wont freak out of undefined variables
source $P_ROOT/tools/shell/modules/variables.sh

# Load up msg types
source $P_ROOT/tools/shell/modules/msg_types.sh

# Check for root user before making tmp dir's
if [[ $EUID -ne 0 ]]; then
        msg_debug "User isn't root, thats good"
    else
        msg_error "User is root and this isn't allowed"
fi

# Load tmp handler and start it
# If we add clean tmp too then docker env wont have args that were passed here before
# So only clean if error is catched by error-handler
source $P_ROOT/tools/shell/modules/tmp_main.sh
create_tmp

# We need build lock function so dev/user cant compile 2 diff pkg's at the same time
# Would be ok in non-docker env but issue handler may kill lock file if error happens ( so lets run it here )
source $P_ROOT/tools/shell/modules/lockup.sh
check_and_setup_lock

# Load issue handler and start it straight away
source $P_ROOT/tools/shell/modules/issue_handler.sh
#start_logging # TODO: Dont cancel out error messages in user/dev cli -->
# ( causes invisible sudo prompt and etc that can cause more issues for docker )
trap interrupt_handle SIGINT INT
trap tmp_err_handle ERR
#trap err_handle HUP TERM QUIT ERR # TODO: Uncomment if start_logging is fixed

# Load up core functions
source $P_ROOT/tools/shell/modules/main_func.sh

# Feed arch manager for different arch based builds ( WIP )
source $P_ROOT/tools/shell/modules/arch_manager.sh
if [ -f $P_ROOT/setup/tmp/is_arch ]; then
    export P_ARCH=$(get_target_arch) # As we may be runned inside container by -d flag
else # Otherwise set up arch flags
    set_arch
    export P_ARCH=$(get_target_arch)
fi

# Load up package src location finder
source $P_ROOT/tools/shell/modules/pkg_location.sh

# Load up dependency resolver
source $P_ROOT/tools/shell/modules/dep_resolver.sh

# Feed our script how to build pkg's
source $P_ROOT/tools/shell/modules/pkg_build.sh

# Feed it again to clean leftovers on pkg's
source $P_ROOT/tools/shell/modules/pkg_clean.sh

# Feed docker instructions for setup
source $P_ROOT/tools/shell/modules/docker_main.sh

# Feed the scriptlet main arch
export ARCH=$(cat $P_ROOT/tools/tmp/is_arch)

# Feed mkiso creator module
source $P_ROOT/tools/shell/modules/mk_iso.sh

# Feed mkiso creator module
source $P_ROOT/tools/shell/modules/dialog_manager.sh

# Read the filename which is named by symlink

tmp010=$(basename $0)

if [ "$tmp010" = "dialog" ]; then
    # If match then run dialog
    dialog_main

    # After good exit clean the tmp
    clean_tmp
fi

##
#   Main Functions
##

# Run basic env setup
env_setup
sleep 2

# Declare pkg list variable here
declare -a PKG_LIST=()

if [ "$#" -lt 1 ]; then
    show_help
fi

while (($# >= 1)); do
    case "$1" in
        --) shift 1; break;;
        -h|--help) show_help;;
        --aarch64) set_aarch64 && intended;; # TODO finish arch manager and needed edits for docker...
        -b|--build) TOOL_BUILD=true;;
        -f|--force-build) echo '--force ' > $TOOL_TEMP/tmpvar001;;
        --no-extract) echo '--noextract ' > $TOOL_TEMP/tmpvar002;;
        --kde) echo "${DOCKER_CONTAINER_KDE_NAME}" > $TOOL_TEMP/docker001;;
        --pkgrel-bump) echo 'TOOL_SKIPBUMP=false' > $TOOL_TEMP/envvar001;;
        --mkiso) export intended && menu_selection;;
        --mkiso-clean-cli) intended && make_clean_iso;;
        --mkiso-plasma-clean-cli) intended && make_plasma_clean_iso;; # Create LiveOS env with plasma desktop
        --mkiso-xfce-clean-cli) intended && make_xfce_clean_iso;; # Create LiveOS env with xfce desktop
        --leave-tmp) echo 'true' > $TOOL_TEMP/.keep_tmp;; # This will be used by docker builder only ( keep away from help menu )
        -c|--clean) TOOL_CLEAN=true;;
        -d|--docker)
        if [ $# -eq 1 ]; then
                msg_error "Docker option cant be used alone ( need to be first arg! )"
        fi
        if [ -z "$1" ]; then
            msg_warning "Make sure to add/use docker experience before adding build/clean option"
            msg_error "nevertheless this option is in wrong place, now panicking"
        else
            export TOOL_DOCKER=true
            echo true > $TOOL_TEMP/is_docker
        fi ;;
        --docker-shell) docker_user_start ;;
        -dr|--docker-reset) docker_reset && message "Docker reset done, exiting" && exit ;;
        *) export PKG_LIST+=("${1}");;
        -*) unknown_option ${1};;
        --*) unknown_option ${1};;
    esac
    shift 1
done

case "$TOOL_BUILD" in
    "true")
        case "$TOOL_DOCKER" in
            "true")
                case "$TOOL_CLEAN" in
                    "true")
                        build_pkg_docker
                        clean_pkg_docker
                    ;;
                    "false")
                        build_pkg_docker
                    ;;
                esac
            ;;
            "false")
                case "$TOOL_CLEAN" in
                    "true")
                        build_pkg
                        clean_pkg
                    ;;

                    "false")
                        build_pkg
                    ;;
                esac
            ;;
        esac
    ;;
    "false")
        case "$TOOL_CLEAN" in
            "true")
                case "$TOOL_DOCKER" in
                    "true")
                        clean_pkg_docker
                    ;;

                    "false")
                        clean_pkg
                    ;;
                esac
            ;;
            "false")
                case "$INTENDED" in
                    "true")
                        # Echo nothing so script can exit by itself
                        echo " "
                    ;;
                    "false")
                        msg_error 'No proper commands have been feed ( please see -h / --help )'
                    ;;
                esac
            ;;
        esac
esac

# On successful exit clean tmp
clean_tmp
