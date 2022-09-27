#!/bin/bash

set -x

# Run multiple JMeter Remote and a Client in docker against calc
# Put enclosing dir to Apache JMeter dir
# source https://www.blazemeter.com/blog/jmeter-distributed-testing-with-docker
#

# Add as many as needed
SERVER_NODE_NAMES=("jmeter-server1" "jmeter-server2" "jmeter-server3")
# Two variables to hold comma/whitespace-separated server names
SERVER_NODE_NAMES_COMMA_SEPARATED=""
SERVER_NODE_NAMES_SPACE_SEPARATED=""
for node_name in "${SERVER_NODE_NAMES[@]}"
do
    SERVER_NODE_NAMES_COMMA_SEPARATED+=",${node_name}"
	SERVER_NODE_NAMES_SPACE_SEPARATED+=" ${node_name}"
done
SERVER_NODE_NAMES_COMMA_SEPARATED=${SERVER_NODE_NAMES_COMMA_SEPARATED:1}
SERVER_NODE_NAMES_SPACE_SEPARATED=${SERVER_NODE_NAMES_SPACE_SEPARATED:1}

CLIENT_NODE_NAME="jmeter-client"
LOAD_TEST="load-test"
NETWORK_NAME="${LOAD_TEST}-remote"

IMAGE_NAME="aashipov/docker:centosdummyjre11u"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
JMETER_CATALOG_HOST=$(pwd)
JMETER_CATALOG_IN_CONTAINER="/dummy/jmeter"
LOAD_TEST_DIR="${JMETER_CATALOG_IN_CONTAINER}/bin/${LOAD_TEST}"
VOLUMES="-v ${JMETER_CATALOG_HOST}:${JMETER_CATALOG_IN_CONTAINER}"
DUMMY_USER="dummy"
JMETER_TMP_DIR_PROP="-Jjmeter.reportgenerator.temp_dir=tmp"

echo "Pull image"
docker pull ${IMAGE_NAME}

echo "Clean up"
docker container stop ${CLIENT_NODE_NAME} ${SERVER_NODE_NAMES_SPACE_SEPARATED}
docker container rm ${CLIENT_NODE_NAME} ${SERVER_NODE_NAMES_SPACE_SEPARATED}
docker network rm ${NETWORK_NAME}

rm -rf ${JMETER_CATALOG_HOST}/client/
rm -rf ${JMETER_CATALOG_HOST}/server/
rm -rf ${JMETER_CATALOG_HOST}/bin/${LOAD_TEST}/result

echo "Create network"
docker network create ${NETWORK_NAME}

# https://unix.stackexchange.com/a/402160
HOST_TO_TEST=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')
ADD_HOST="--add-host=host.to.test:${HOST_TO_TEST}"

echo "Create servers"
for server_node_name in "${SERVER_NODE_NAMES[@]}"
do
	docker run -d --hostname=${server_node_name} --name=${server_node_name} --network=${NETWORK_NAME} -u=${DUMMY_USER}:${DUMMY_USER} ${ADD_HOST} ${VOLUMES} ${IMAGE_NAME} ${JMETER_CATALOG_IN_CONTAINER}/bin/jmeter -n -s -Jclient.rmi.localport=7000 -Jserver.rmi.ssl.disable=true -Jserver.rmi.localport=60000 -j ${JMETER_CATALOG_IN_CONTAINER}/server/${server_node_name}_${TIMESTAMP}.log ${JMETER_TMP_DIR_PROP}
done

echo "Create client"
docker run -d --hostname=${CLIENT_NODE_NAME} --name=${CLIENT_NODE_NAME} --network=${NETWORK_NAME} -u=${DUMMY_USER}:${DUMMY_USER} ${ADD_HOST} ${VOLUMES} ${IMAGE_NAME} ${JMETER_CATALOG_IN_CONTAINER}/bin/jmeter -n -X -Jclient.rmi.localport=7000 -Jserver.rmi.ssl.disable=true -R ${SERVER_NODE_NAMES_COMMA_SEPARATED} -t ${LOAD_TEST_DIR}/${LOAD_TEST}.jmx -l ${JMETER_CATALOG_IN_CONTAINER}/client/Load-test_${TIMESTAMP}.jtl -j ${JMETER_CATALOG_IN_CONTAINER}/client/${CLIENT_NODE_NAME}_${TIMESTAMP}.log -e -o ${JMETER_CATALOG_IN_CONTAINER}/client/web-report-${TIMESTAMP} ${JMETER_TMP_DIR_PROP}
