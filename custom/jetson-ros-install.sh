# Set up steps
apt update

mkdir -p /ros2_ws/src && cd /ros2_ws/src

# Clone repositories
git clone git@github.com:airacingtech/race_common.git -b ucsd_gokart_launch
cd race_common
make vcs-import VCS_FILE=race.common.${ROS_DISTRO}.repos # Common packages
make vcs-import VCS_FILE=jetson.${ROS_DISTRO}.repos # Jetson packages
make vcs-import VCS_FILE=ucsd_gokart.${ROS_DISTRO}.repos # Gokart packages
cd ..

# # Install dependencies
# cd /ros2_ws && rosdep update && rosdep install -y -r --rosdistro ${ROS_DISTRO} --ignore-src --from-paths src

# Build selected packages
cd /ros2_ws && colcon build --packages-up-to gkc

# Delete apt cache
apt clean && rm -rf /var/lib/apt/lists/*