##
# Load all pieces of repo system moudles here
##

# Load global functions that are used by beelow modules
source $P_ROOT/build/toolset/shell/modules/repo_updater/repo_common.sh
loaded "    repo -> common functions"

# Functions to update local repositories
source $P_ROOT/build/toolset/shell/modules/repo_updater/repo_update.sh
loaded "    repo -> update functions"

# Functions to push local repository to server
source $P_ROOT/build/toolset/shell/modules/repo_updater/repo_push.sh
loaded "    repo -> push functions"

# Functions from all modules to make one working big function out of
source $P_ROOT/build/toolset/shell/modules/repo_updater/repo_system.sh
loaded "    repo -> system functions"
