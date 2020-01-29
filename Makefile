
DOCKER_IMAGE_NAME:=dynamocoder
DOCKER_TAG:=dev
DOCKER_NAME=$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)


build_docker:
	@docker build -t $(DOCKER_NAME) -f .docker/Dockerfile .

run_docker_tests:
	@docker run \
		--volume '$(PWD):/build' \
		--workdir /build \
		$(DOCKER_NAME) \
		swift build && swift test --enable-test-discovery
