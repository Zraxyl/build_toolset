##
# Here we will export all variables
##

export DRUNK_BUILD=false
export DRUNK_CLEAN=false
export DRUNK_DOCKER=false
export DRUNK_TEMP=$P_ROOT/tools/tmp
export DRUNK_SKIPBUMP=true
export ISO_ROOT=$P_ROOT/drunk_iso
export DRUNK_USER=$(whoami)

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
# Docker related ( Defaults )
##
export DOCKER_CONTAINER_NAME=drunk_dev
export DOCKER_CONTAINER_KDE_NAME=kde_dev
export DOCKER_CONTAINER_KDE=false
export DOCKER_USER_FOLDER=/home/developer

##
# Developer friend
##

export SHOW_DEBUG=true

# This is needed so system catches up with all exports
sleep 0.1
