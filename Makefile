PWD = $(shell pwd)
IMAGE_NAME = $(shell basename ${PWD})
BASE_IMAGE = $(shell grep Dockerfile -e FROM | cut -d ' ' -f 2)
DOCKER_SOCKET = /var/run/docker.sock
BUILD_ARGS = --rm
TPACK_IMAGE = 1and1internet/testpack-framework
DOCKER_ID_USER = dezinger

all: pull build push

pull:
	##
	## Pulling image updates from registry
	##
	for IMAGE in ${BASE_IMAGE} ${TPACK_IMAGE}; \
		do docker pull $${IMAGE}; \
	done

build:
	##
	## Starting build of image ${IMAGE_NAME}
	##
	docker build ${BUILD_ARGS} --tag ${DOCKER_ID_USER}/${IMAGE_NAME} .

test:
	docker run --rm -i -t -v ${DOCKER_SOCKET}:/var/run/docker.sock -v ${PWD}/:/mnt/ -v ${TESTS_LOCAL}/:/drone-tests/ -e IMAGE_NAME=${IMAGE_NAME} ${TPACK_IMAGE}

clean:
	##
	## Removing docker images .. most errors during this stage are ok, ignore them
	##
	for IMAGE in ${BASE_IMAGE} ${TPACK_IMAGE}; \
		do docker rmi $${IMAGE}; \
	done

push:
	##
	## Push image
	##
	docker login
	#docker tag ${IMAGE_NAME} ${DOCKER_ID_USER}/${IMAGE_NAME}
	docker push ${DOCKER_ID_USER}/${IMAGE_NAME}

.PHONY: all pull build test clean
