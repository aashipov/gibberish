#!/bin/bash

set -x

DISTRO=${1}
CONTAINER_NAME=gibberish
IMAGE="aashipov/${CONTAINER_NAME}"
TAG="purejava${DISTRO}"

usage() {
    echo "usage: $(basename $0) distro"
    echo "  distro  - alpine, centos or corretto (on alpine)"
}

stop_and_remove_container(){
  docker stop ${CONTAINER_NAME}
  docker rm ${CONTAINER_NAME}
}

build() {
  docker pull ${IMAGE}:${TAG}
  if [[ $? -ne 0 ]] ; then 
    docker build --file=Dockerfile.${DISTRO} --tag ${IMAGE}:${TAG} .
    docker push ${IMAGE}:${TAG}
  fi
}

run() {
  docker run -d --name=${CONTAINER_NAME} --hostname=${CONTAINER_NAME} -p 8080:8080 ${IMAGE}:${TAG}
}

### Main script

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

stop_and_remove_container
build
run
