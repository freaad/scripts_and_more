CAFFE_NAME=caffe
CAFFE_ID=`docker ps -aqf "name=^/${CAFFE_NAME}$"`
CAFFE_HOST_DATA_DIR=/data/
if [ -z "${CAFFE_ID}" ]; then
    echo "Creating new Caffe container."
    nvidia-docker run -it --privileged -p 8888:8888 -p 5000:5000 -v ${CAFFE_HOST_DATA_DIR}:/data/:rw -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix${DISPLAY} --name=${CAFFE_NAME} -e PASSWORD="p" bvlc/caffe:gpu bash
else
    echo "Found Caffe container: ${CAFFE_ID}."
    # Check if the container is already running and start if necessary.
    if [ -z `docker ps -qf "name=^/${CAFFE_NAME}$"` ]; then
        xhost +local:${CAFFE_ID}
        echo "Starting and attaching to Caffe container..."
        docker start ${CAFFE_ID}
        docker attach ${CAFFE_ID}
    else
        echo "Found running Caffe container, attaching bash to it..."
        docker exec -it --privileged ${CAFFE_ID} bash
    fi
fi

