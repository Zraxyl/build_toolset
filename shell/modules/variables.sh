##
# Here we will export all variables
##

export TOOL_BUILD=false
export TOOL_CLEAN=false
export TOOL_DOCKER=false
export TOOL_OUT=$P_ROOT/out
export TOOL_TEMP=$TOOL_OUT/tmp
export TOOL_CHECKS=$TOOL_OUT/checks
export TOOL_SKIPBUMP=true
export ISO_ROOT=$TOOL_OUT/system_iso
export TOOL_USER=$(whoami)
export TOOL_MAIN_NAME=EVOLINX

export USE_STAGING=yes

##
# Failsafe incase of error
##

export PKG_NAME=none
export PKG_ROOT_DIR=none
export depend=none
export makedepend=none
export FULL_DEP_LIST=none
export donenow=0
export PKG_VERSION=none
export PKG_REL=none
export WHAT_AM_I=none
export srel=" "
export INTENDED=idk

##
# Override variables
##
export IGNORE_LOCKUP=yes

export DEV_FOLDER="${P_ROOT}/build/developer"

##
# Distro specific exports
##

# Package manager side changes are WIP still so bottle will be used anyways
export PACKAGE_MANAGER=bottle

# This is used in mkiso mainly vmlinuz-DISTRONAME
export DISTRO_NAME=evolinx

##
# ISO Creator specific variables
##

# Specific tool names
export STRAP="base-strap"

# Rootfs packages
export CLI_PKG="base-system nano dracut base-install-scripts sudo parted libmd"
#export CLI_PKG="base-minimal util-linux coreutils libseccomp linux"
export INSTALLER_PKG="base-system nano dracut wireless-tools base-install-scripts sudo parted libmd plymouth plasma-desktop konsole"

##
# Docker related ( Defaults )
##

export DOCKER_IMAGE_NAME="hilledkinged/evolinx"
export DOCKER_IMAGE_NAME_TEMP="evolinx/temp_img"
export DOCKER_BASE_CONTAINER_NAME=evolinx_base
export DOCKER_KDE_CONTAINER_NAME=evolinx_kde
export DOCKER_BUILD_CONTAINER_NAME=evolinx_build
export DOCKER_BUILD_CONTAINER_NAME_KDE=evolinx_build_kde
export DOCKER_CONTAINER_NAME=none
export DOCKER_CONTAINER_KDE=false
export DOCKER_USER_FOLDER=/home/developer
export DOCKER_PKG="sudo nano mpfr mpc base-devel m4 git grep gawk file"
export DOCKER_PKG_KDE="ceph qt5 qt6 cmake meson ninja"

##
# Developers friend
##

export SHOW_DEBUG=true

# This is needed so system catches up with all exports
sleep 0.1
