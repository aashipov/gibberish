#!/bin/bash

# Run JMeter load test via compose

check_cgroup_v1_enabled() {
    mount | grep -q "cgroup "
    if [[ $? -ne 0 ]]; then
        printf "Enable cgroup v1 for java 11 not to OOM in containers\n"
        exit 1
    fi
}

stop_and_remove_container() {
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
}

main() {
    local TAKES_COUNT=5
    local IMPLEMENTATIONS=("pure" "pure-temurin" "pure-native" "dotnet" "go" "nodejs" "python")
    for implementation in "${IMPLEMENTATIONS[@]}"; do
        local TAKE_NO=1
        while [ ${TAKE_NO} -le ${TAKES_COUNT} ]; do
            stop_and_remove_container
            docker run -d --name=${CONTAINER_NAME} -p 8080:8080 aashipov/gibberish:centos-${implementation}
            rm -rf ${_SCRIPT_DIR}/bin/gibberish-load-test/result
            rm -rf ${_SCRIPT_DIR}/client
            rm -rf ${_SCRIPT_DIR}/server
            docker-compose -f docker-compose-jmeter.yml up
            docker-compose -f docker-compose-jmeter.yml down
            cp ${_SCRIPT_DIR}/client/gibberish-load-test.jtl ${_SCRIPT_DIR}/stats/${implementation}-${TAKE_NO}.jtl
            TAKE_NO=$((${TAKE_NO} + 1))
            stop_and_remove_container
        done
    done

    cd ${_SCRIPT_DIR}/stats
    ./do-stats.bash
}

# Main procedure

# https://stackoverflow.com/a/1482133
_SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$0")")
cd ${_SCRIPT_DIR}

if grep -q "HOST_TO_TEST=<host-IP>" ${_SCRIPT_DIR}/.env; then
    printf "Replace <host-IP> with host IP in .env variable HOST_TO_TEST and repeat\n"
    exit 1
fi

CONTAINER_NAME=gibberish

check_cgroup_v1_enabled
main
