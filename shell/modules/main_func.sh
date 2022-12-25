##
#   Setup and export env for main script
##

env_setup() {
    # Safety check so things dont get re-runned
    if [ -f $P_ROOT/tools/checks/is_checked ]; then
        drunk_debug "Developer has passed initally required steps"
    else
        install_required_deps
        check_projects

        # Tell the script that inital setup is done
        touch $P_ROOT/tools/checks/is_checked
    fi
}

intended() {
	export INTENDED=true
}

check_projects() {
    if [ -d $P_ROOT/pkgbuild ]; then
        drunk_debug "Dev has pkgbuild folder, skipping initial bootstrap"
    else
        drunk_warn "Missing pkgbuild project, running initial bootstrap"
        run_bootstrap
    fi
}

run_bootstrap() {
    drunk_debug "Function run_bootstrap was started"
    git clone https://git.it-kuny.ch/drunk/drunk-pkgbuild.git $P_ROOT/pkgbuild

    create_folders

    read -p "Do you wish to clone additional sources?" yn
    case $yn in
        [Yy]* ) clone_sources;;
        [Nn]* ) echo " ";;
        * ) echo "Assuming no";;
    esac
    read -p "Do you wish to clone some repos?" yn
    case $yn in
        [Yy]* ) clone_repos;;
        [Nn]* ) echo " ";;
        * ) echo "Assuming no";;
    esac
}

install_required_deps() {
    REQ_PKGS=" docker nano mpfr mpc m4 base-devel"
    drunk_message "Please allow this one time to run inital setup of bottle install"
    sudo bottle -Sy --needed --noconfirm --disable-download-timeout $REQ_PKGS
}

create_folders() {
    mkdir -p drunk-source repository/x86_64/pkgs/{core,cross_tools,extra,extra32,games,layers,proprietary,server,kde,gnome,xfce,python,perl,pentest}
}

clone_sources() {
    # Only add neccessary repos
    git clone https://git.it-kuny.ch/drunk/source-code/bottle.git drunk-source/bottle
}

clone_repos() {
    # Lets clone all repos ( easier to push later on )
    for repo in core extra extra32 cross_tools games gnome kde layers pentest perl proprietary python server xfce
    do
        git clone https://git.it-kuny.ch/drunk/repository/x86_64/$repo.git repository/x86_64/$repo
    done
}

unknown_option() {
    drunk_warn "Unknown option ' $@ '"
    show_help
}

show_help() {
    drunk_message "#########################"
    drunk_message "# Usage of drunk script #"
    drunk_message "#########################"
    echo " "
    drunk_message "###"
    drunk_message "# Arch based options"
    drunk_message "###"
    drunk_message " --aarch64                : Will use aarch64 pkgbuild files to build its packages"
    echo " "
    drunk_message "###"
    drunk_message "# Build options"
    drunk_message "###"
    drunk_message " -b or --build pkgname    : Will build a pkg you asked for ( Assumes you have deps installed )"
    drunk_message " -f or --force-build      : Will add -f to makepkg so it will ignore if pkg is already built"
    drunk_message " -c or --clean            : Will clean up pkgbuild leftovers"
    drunk_message " --no-extract             : Will add -e to makepkg so prepare + extracting src over existing one is skipped ( basically resume compile flag )"
    drunk_message " --pkgrel-bump            : This is useful when youre clean recompiling pkg"
    echo " "
    drunk_message "###"
    drunk_message "# Docker options"
    drunk_message "###"
    drunk_message " -d or --docker           : This will make pkg builder use docker environment"
    drunk_message " -dr or --docker-reset    : This reset's docker container ( if it breaks for some reson )"
    drunk_message " --kde                    : Will use drunk container that has qt5 and qt6 preinstalled ( Add BEFORE -d option only )"
    drunk_message "     |- EXAMPLE: ./drunk --kde -d -b plasma-workspace"
    drunk_message " --docker-shell           : This will only work with/without --kde option and wont take any other arg's"
    echo " "
    drunk_message "###"
    drunk_message "# ISO Creator options"
    drunk_message "###"
    drunk_message " --mkiso                  : This will prompt you do the iso creator menu ( makes LiveOS Installer CLI )"
    drunk_message " --mkiso-clean-cli        : Will skip mkiso menu and make clean base ISO"
    drunk_message " --mkiso-plasma-clean-cli : Will skip mkiso and make clean plasma-desktop ISO"
    drunk_message " --mkiso-xfce-clean-cli : Will skip mkiso and make clean xfce-desktop ISO"

    clean_tmp # Also clean tmp files before exit
    exit 1
}
