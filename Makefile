#import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= env.mk
include $(cnf)
CACHE = $(REGISTRY)/$(IMAGE):cache
IMG = $(REGISTRY)/$(IMAGE)

OCTOPRINT_VERSION?= $(shell ./scripts/version.sh "OctoPrint/OctoPrint")
IMG_TAG=${OCTOPRINT_VERSION}-python3

.DEFAULT_GOAL := build

clean:
	docker stop buildkit && docker rm buildkit

install: ./scripts/install.sh
	
binfmt: 
	@docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64

prepare: 
	@docker buildx create --use

build:
	@echo '[default]: building local octoprint image with all default options'
	@docker build -t octoprint .

dry-run:
	@echo '[buildx]: building image: ${IMG}:${IMG_TAG} for all architectures'

buildx:
	@echo '[buildx]: building image: ${IMG}:${IMG_TAG} for all architectures'
	@docker buildx build --load --platform $(PLATFORMS) \
		--cache-from ${CACHE} \
		--cache-to	${CACHE} \
		--build-arg PYTHON_BASE_IMAGE=$(PYTHON_BASE_IMAGE) \
		--build-arg tag=${OCTOPRINT_VERSION} \
		--progress plain -t ${IMG}:${IMG_TAG} .

buildx-push:
	@echo '[buildx]: building and pushing images: ${IMG}:${IMG_TAG} for all supported architectures'
	docker buildx build --push --platform $(PLATFORMS) \
		--cache-from ${CACHE} \
		--cache-to	${CACHE} \
		--build-arg PYTHON_BASE_IMAGE=$(PYTHON_BASE_IMAGE) \
		--build-arg tag=${OCTOPRINT_VERSION} \
		--progress plain -t ${IMG}:${IMG_TAG} .
