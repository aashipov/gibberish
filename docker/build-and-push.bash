#!/bin/bash

# Builds the images

fill_target_to_tag() {
    TARGET_TO_TAG["jre17"]="jre17"
    TARGET_TO_TAG["javaresult "]="pure"
    TARGET_TO_TAG["temurin17"]="temurin17"
    TARGET_TO_TAG["temurinresult"]="pure-temurin"
    TARGET_TO_TAG["dotnet6"]="dotnet6"
    TARGET_TO_TAG["dotnetresult "]="dotnet"
    TARGET_TO_TAG["golangresult"]="go"
    TARGET_TO_TAG["nodejsresult"]="nodejs"
    TARGET_TO_TAG["pythonresult"]="python"
    TARGET_TO_TAG["rustresult "]="rust-actix-web"
}

build() {
    for target in "${!TARGET_TO_TAG[@]}"; do
        DOCKER_BUILDKIT=1 docker build . --file=docker/Dockerfile.${DISTRO} --target=${target} --tag=aashipov/gibberish:${DISTRO}-${TARGET_TO_TAG[${target}]}
    done
}

closure() {
    set -ex
    local _SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$0")")
    cd ${_SCRIPT_DIR}/..

    local DISTRO="fedora"

    declare -A TARGET_TO_TAG
    fill_target_to_tag

    build
}

closure
