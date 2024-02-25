.PHONY build-ubuntu-cpu-x86_64:
build-ubuntu-cpu-x86_64:
	@IMG_NAME=${IMG_NAME}
	@BASE_FROM=${BASE_FROM}

	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build \
		--network=host \
		-f Dockerfile \
		--target final \
		--build-arg BASE_FROM=${BASE_FROM} \
		--build-arg APT_PACKAGES=apt-packages \
		--build-arg CUSTOM_INSTALL_FILE=custom-install.sh \
		--build-arg TEST_INSTALL_FILE=test-layer.sh \
		--build-arg BASH_SETTINGS_FILE=default \
		-t ${IMG_NAME} .

.PHONY build-l4t:
build-l4t:
	@IMG_NAME=${IMG_NAME}
	@BASE_FROM=${BASE_FROM}
	@TARGET=${TARGET}

	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build \
		--network=host \
		-f Dockerfile \
		--target ${TARGET} \
		--build-arg BASE_FROM=${BASE_FROM} \
		--build-arg APT_PACKAGES=jetson-packages \
		--build-arg CUSTOM_INSTALL_FILE=jetson-install.sh \
		--build-arg TEST_INSTALL_FILE=test-layer.sh \
		--build-arg BASH_SETTINGS_FILE=jetson \
		--build-arg PIP_PACKAGES=jetson-pip \
		-t ${IMG_NAME} .

.PHONY run-l4t:
run-l4t:
	@IMG_NAME=${IMG_NAME}
	@HOME=${HOME}
	sudo docker run --runtime nvidia -it \
		--name donkey\
		--privileged \
		--rm \
		--network=host \
		--device-cgroup-rule='c 189:* rmw' \
		--device /dev/video0 \
		--volume='/dev/input:/dev/input' \
		-v /dev/bus/usb:/dev/bus/usb \
		-v ${HOME}/Moises/container-data:/root/projects \
		${IMG_NAME}

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
