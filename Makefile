.PHONY build-ubuntu-cpu-x86_64:
build-ubuntu-cpu-x86_64:
	@IMG_NAME=${IMG_NAME}
	@BASE_FROM=${BASE_FROM}

	DOCKER_BUILDKIT=1 docker build \
		--network=host \
		-f Dockerfile \
		--target test \
		--build-arg BASE_FROM=${BASE_FROM} \
		--build-arg APT_PACKAGES=webtop-packages \
		--build-arg BASH_SETTINGS_FILE=webtop \
		--build-arg CUSTOM_INSTALL_FILE=webtop-install.sh \
		--build-arg PIP_PACKAGES=empty \
		--build-arg PIP_GPU_PACKAGES=empty \
		--build-arg TEST_INSTALL_FILE=empty-layer.sh \
		-t ghcr.io/triton-ai/webtop:${TARGET} .


.PHONY build-l4t-donkey:
build-l4t-donkey:
	@BASE_FROM=${BASE_FROM}
	@TARGET=${TARGET}

	DOCKER_BUILDKIT=1 docker build \
		--network=host \
		-f Dockerfile \
		--target ${TARGET} \
		--ssh default=${SSH_AUTH_SOCK} \
		--build-arg BASE_FROM=${BASE_FROM} \
		--build-arg APT_PACKAGES=empty-packages \
		--build-arg BASH_SETTINGS_FILE=jetson \
		--build-arg CUSTOM_INSTALL_FILE=jetson-install.sh \
		--build-arg PIP_PACKAGES=jetson-pip \
		--build-arg PIP_GPU_PACKAGES=jetson-ros \
		--build-arg TEST_INSTALL_FILE=empty-layer.sh \
		-t ghcr.io/triton-ai/l4t-donkey:${TARGET} .

.PHONY build-l4t-ros:
build-l4t-ros:
	@BASE_FROM=${BASE_FROM}
	@TARGET=${TARGET}

	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build \
		--runtime=nvidia
		--network=host \
		-f Dockerfile \
		--target ${TARGET} \
		--ssh default=${SSH_AUTH_SOCK} \
		--build-arg BASE_FROM=${BASE_FROM} \
		--build-arg APT_PACKAGES=jetson-ros-packages \
		--build-arg BASH_SETTINGS_FILE=jetson-ros \
		--build-arg CUSTOM_INSTALL_FILE=jetson-ros-install.sh \
		--build-arg PIP_PACKAGES=jetson-ros \
		--build-arg PIP_GPU_PACKAGES=jetson-ros \
		--build-arg TEST_INSTALL_FILE=test-layer.sh \
		-t ghcr.io/triton-ai/l4t:donkey-${TARGET} .

.PHONY run-l4t-ros:
run-l4t-ros:
	@TARGET=${TARGET}
	docker run --runtime nvidia -it \
		--name ros2\
		--privileged \
		--rm \
		--network host \
		--device-cgroup-rule='c 189:* rmw' \
		--device /dev/video0 \
		--volume='/dev/input:/dev/input' \
		--volume='${SSH_AUTH_SOCK}:/ssh-agent' \
		--volume='~/docker_data/donkey:~/projects'
		--env SSH_AUTH_SOCK=/ssh-agent \
		-v /dev/bus/usb:/dev/bus/usb \
		ghcr.io/triton-ai/l4t:${TARGET}

PHONY run-l4t-donkey:
run-l4t-donkey:
	@TARGET=${TARGET}
	nvidia-docker run -it \
		--name donkey\
		--privileged \
		--rm \
		--network host \
		--device-cgroup-rule='c 189:* rmw' \
		--device /dev/video0 \
		--volume='/dev/input:/dev/input' \
		--volume='${SSH_AUTH_SOCK}:/ssh-agent' \
		--env SSH_AUTH_SOCK=/ssh-agent \
		-v /dev/bus/usb:/dev/bus/usb \
		--volume='/home/jetson/Moises/docker:/root/projects' \
		ghcr.io/triton-ai/l4t-donkey:${TARGET}

.PHONY run-ubuntu-cpu-x86_64:
run-ubuntu-cpu-x86_64:
	@IMG_NAME=${IMG_NAME}
	docker run \
		--name=webtop \
		--rm \
		-e PUID=1000 \
		-e PGID=1000 \
		-e TZ=Etc/UTC \
		-p 8080:3000 \
		${IMG_NAME}

# .PHONY push:
# push:
# 	docker push ghcr.io/triton-ai/l4t:test
