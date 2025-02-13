##
# Load all pieces of docker moudles here
##

# Load global functions that are used by beelow modules
source $P_ROOT/build/toolset/shell/modules/docker/docker_base_functions.sh
loaded "    docker -> base functions"

# Load docker image setup module
# source $P_ROOT/build/toolset/shell/modules/docker/docker_setup_image.sh
# loaded "    docker -> image setup"

source $P_ROOT/build/toolset/shell/modules/docker/docker_setup_main_container.sh
loaded "    docker -> base container setup"

source $P_ROOT/build/toolset/shell/modules/docker/docker_setup_kde_container.sh
loaded "    docker -> kde container setup"

source $P_ROOT/build/toolset/shell/modules/docker/docker_setup_build_container.sh
loaded "    docker -> build container setup"

source $P_ROOT/build/toolset/shell/modules/docker/docker_setup_build_container_kde.sh
loaded "    docker -> kde build container setup"

sleep 1

source $P_ROOT/build/toolset/shell/modules/docker/imgsys/imgsys_base.sh
loaded "    imgsys -> base functions"

source $P_ROOT/build/toolset/shell/modules/docker/imgsys/imgsys_build.sh
loaded "    imgsys -> build functions"

sleep 1
source $P_ROOT/build/toolset/shell/modules/docker/docker_system.sh
loaded "    docker -> system"
