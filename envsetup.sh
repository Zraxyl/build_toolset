#!/bin/bash

set -e -o pipefail -u

##
#   Export some needed things for head script to work with
##

# Dont allow to run this script in other places than specified symlink dir ( So no unknown issues occure )
if [ -f build/toolset/envsetup.sh ];then
    cd "$(dirname "$0")"
else
    echo "Dont run this in other places than its symlink root dir ( Only in a project root dir that has folder called build/toolset )!!!"
    exit 1
fi

export P_ROOT=$(pwd)

# Load all modules with load_module script
source $P_ROOT/build/toolset/load_modules.sh

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

while (("$#" >= 1)); do
    case "$1" in
        --) shift 1; break;;
        -h|--help) show_help;;
        --aarch64) set_aarch64 && intended;; # TODO finish arch manager and needed edits for docker...
        -b|--build) TOOL_BUILD=true;;
        -f|--force-build) echo '--force ' > $TOOL_TEMP/tmpvar001;;
        --no-extract) echo '--noextract ' > $TOOL_TEMP/tmpvar002;;
        --shell) itshell_spawn_interactive_shell && clean_tmp;;
        --kde) echo "${DOCKER_BUILD_CONTAINER_NAME_KDE}" > $TOOL_TEMP/docker001;;
        --pkgrel-bump) echo 'TOOL_SKIPBUMP=false' > $TOOL_TEMP/envvar001;;
        --mkiso) export intended && iso_build_request dialog;;
        --mkiso-clean-cli) intended && iso_build_request cli;;
        --mkiso-plasma-clean-cli) intended && iso_build_request plasma;; # Create LiveOS env with plasma desktop
        --leave-tmp) echo 'true' > $TOOL_TEMP/.keep_tmp;; # This will be used by docker builder only ( keep away from help menu )
        -c|--clean) TOOL_CLEAN=true;;
        --repo-update) echo "WIP" ;;
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
        --docker-check) docker_check_health && clean_tmp ;;
        --docker-shell) docker_shell_session ;;
        -dr|--docker-reset) docker_reset_build && message "Docker reset done, exiting" && clean_tmp ;;
        # Docker image creator + pusher
        --imgsys-push) echo true > $TOOL_TEMP/imgsys_push ;;
        --imgsys-amd64) imgsys_build && clean_tmp;;
        --imgsys-arm64) msg_error "Imgsys dosent support arm64 builds yet" && clean_tmp;;
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

force_clean_tmp
