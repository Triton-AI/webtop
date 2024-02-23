.PHONY build-ubuntu-cpu-x86_64:
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

.PHONY run-ubuntu-cpu-x86_64:
	@IMG_NAME=${IMG_NAME}
	docker run \
		--name=webtop \
		--rm \
		-e PUID=1000 \
		-e PGID=1000 \
		-e TZ=Etc/UTC \
		-p 8080:3000 \
		${IMG_NAME}
