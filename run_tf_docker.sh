TF_NAME=tf
TF_ID=`docker ps -aqf "name=^/${TF_NAME}$"`
TF_HOST_DATA_DIR=/data/
if [ -z "${TF_ID}" ]; then
    echo "Creating new TF container."
    nvidia-docker run -it --privileged --network=host -p 8888:8888 -p 6006:6006 -v ${TF_HOST_DATA_DIR}:/data/:rw -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix${DISPLAY} --name=${TF_NAME} -e PASSWORD="p" gcr.io/tensorflow/tensorflow:latest-gpu bash
else
    echo "Found TF container: ${TF_ID}."
    # Check if the container is already running and start if necessary.
    if [ -z `docker ps -qf "name=^/${TF_NAME}$"` ]; then
        xhost +local:${TF_ID}
        echo "Starting and attaching to TF container..."
        docker start ${TF_ID}
        docker attach ${TF_ID}
    else
        echo "Found running TF container, attaching bash to it..."
        docker exec -it --privileged ${TF_ID} bash
    fi
fi

