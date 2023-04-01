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
export TOOL_MAIN_NAME=EVOLIX

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
IGNORE_LOCKUP=none

##
# Distro specific exports
##

# Package manager side changes are WIP still so bottle will be used anyways
export PACKAGE_MANAGER=bottle

# This is used in mkiso mainly vmlinuz-DISTRONAME
export DISTRO_NAME=evolinx

##
# Docker related ( Defaults )
##
export DOCKER_IMAGE_NAME="hilledkinged/evolinx"

export DOCKER_CONTAINER_NAME=evolinx_dev
export DOCKER_CONTAINER_KDE_NAME=evolinx_kde_dev
export DOCKER_CONTAINER_KDE=false
export DOCKER_USER_FOLDER=/home/developer

##
# Developers friend
##

export SHOW_DEBUG=false

# This is needed so system catches up with all exports
sleep 0.1
