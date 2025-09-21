##
# Local conf for user/dev
# EXAMPLE FROM: build/toolset/shell/modules/local_conf.sh
#
# * Here you the dev/user can override toolset variables too if needed
# * Also make sure to keep up to date with toolset example conf as more things may be added
##

##
# Makepkg stuff
##
export PACKAGER='Unknown Developer <unknown@unknown.invalid>'

##
# Repo target ftp configuration
##
export REPO_USER="none"
export REPO_IP="none"
export REPO_TARGET_PATH="none"

# This overrides toolset repo type
# Can be either stable or staging
export REPO_TYPE="staging"

# Set or Get system arch
# either amd64 or aarch64
export REPO_ARCH=$(cat $TOOL_TEMP/docker_arch)

# Local repository stuff
# By string the default is ...../repo/staging/amd64
export REPO_LOCAL_PATH="${P_ROOT}/repo/${REPO_TYPE}/${REPO_ARCH}"

# Current list of official repos
export REPO_LIST="core cross_toos extra extra32 games gnome kde layers pentest perl proprietary python server xfce"

# Repos that are locally available
# This list gets populated automatically by toolset on runtime
export REPO_LOCAL_LIST=""

