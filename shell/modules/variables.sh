##
# Here we will export all variables
##

export TOOL_VERSION_CODE=1005

export TOOL_BUILD=false
export TOOL_CLEAN=false
export TOOL_DOCKER=false
export TOOL_OUT=$P_ROOT/out
export TOOL_TEMP=$TOOL_OUT/tmp
export TOOL_CHECKS=$TOOL_OUT/checks
export TOOL_SKIPBUMP=true
export ISO_ROOT=$TOOL_OUT/system_iso
export TOOL_USER=$(whoami)
export TOOL_MAIN_NAME=ZRAXYL

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

# Use local copy of package repositories
export USE_STAGING_LOCAL=yes

# This is used in mkiso mainly vmlinuz-DISTRONAME
export DISTRO_NAME=zraxyl

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

export DOCKER_IMAGE_NAME="zraxyl/zraxyl"
export DOCKER_IMAGE_ARCH="none"

export DOCKER_IMAGE_NAME_TEMP="zraxyl/temp_img"
export DOCKER_BASE_CONTAINER_NAME=zraxyl_base
export DOCKER_KDE_CONTAINER_NAME=zraxyl_kde
export DOCKER_BUILD_CONTAINER_NAME=zraxyl_build
export DOCKER_BUILD_CONTAINER_NAME_KDE=zraxyl_build_kde
export DOCKER_CONTAINER_NAME=none
export DOCKER_CONTAINER_KDE=false
export DOCKER_USER_FOLDER=/home/developer

# X86_64
export DOCKER_AMD64_PKG="sudo nano mpfr mpc base-devel m4 git grep gawk file linux"
export DOCKER_AMD64_PKG_KDE="ceph qt5 qt6 cmake meson ninja linux"

# AArch64
export DOCKER_AARCH64_PKG="sudo nano mpfr mpc m4 git grep gawk cmake meson ninja file make automake texinfo autoconf linux-headers"
export DOCKER_AARCH64_PKG_KDE="cmake meson ninja"

##
# Developers friend
##

export SHOW_DEBUG=false

# This is needed so system catches up with all exports
sleep 0.1
