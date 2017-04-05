#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Expected the name of the container."
    exit
fi

CONTAINER_NAME=$1
CONTAINER_ID=`docker ps -aqf "name=^/${CONTAINER_NAME}$"`
CONTAINER_HOST_DATA_DIR=/data/
if [ -z "${CONTAINER_ID}" ]; then
    echo "Creating new ${CONTAINER_NAME} container."
    nvidia-docker run -it --network=host -p 8888:8888 -v ${CONTAINER_HOST_DATA_DIR}:/data/:rw -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix${DISPLAY} --name=${CONTAINER_NAME} -e PASSWORD="p" continuumio/anaconda3 bash
else
    echo "Found ${CONTAINER_NAME} container: ${CONTAINER_ID}."
    # Check if the container is already running and start if necessary.
    if [ -z `docker ps -qf "name=^/${CONTAINER_NAME}$"` ]; then
        xhost +local:${CONTAINER_ID}
        echo "Starting and attaching to ${CONTAINER_NAME} container..."
        docker start ${CONTAINER_ID}
        docker attach ${CONTAINER_ID}
    else
        echo "Found running ${CONTAINER_NAME} container, attaching bash to it..."
        docker exec -it --privileged ${CONTAINER_ID} bash
    fi
fi

