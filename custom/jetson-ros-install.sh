# Set up steps
apt update

# Clone repositories
git clone git@github.com:airacingtech/race_common.git -b ucsd_gokart_launch
cd race_common
make vcs-import VCS_FILE=race.common.${ROS_DISTRO}.repos # Common packages
make vcs-import VCS_FILE=jetson.${ROS_DISTRO}.repos # Jetson packages
make vcs-import VCS_FILE=ucsd_gokart.${ROS_DISTRO}.repos # Gokart packages


make rosdep-install

# Delete apt cache
apt clean && rm -rf /var/lib/apt/lists/*