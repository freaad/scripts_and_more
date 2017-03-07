PX4_NAME=px4-ros
PX4_ID=`docker ps -aqf "name=^/${PX4_NAME}$"`
if [ -z "${PX4_ID}" ]; then
    echo "Creating new px4 container."
    docker run -it --privileged --network=host -v /data/:/data/:rw -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix${DISPLAY} -p 14556:14556/udp --name=${PX4_NAME} px4io/px4-dev-ros bash
else
    echo "Found px4 container: ${PX4_ID}."
    # Check if the container is already running and start if necessary.
    if [ -z `docker ps -qf "name=^/${PX4_NAME}$"` ]; then
        xhost +local:${PX4_ID}
        echo "Starting and attaching to px4 container..."
        docker start ${PX4_ID}
        docker attach ${PX4_ID}
    else
        echo "Found running px4 container, attaching bash to it..."
        docker exec -it ${PX4_ID} bash
    fi
fi

# docker run -it --privileged -v /media/alexey/Data/Data/:/data/:rw -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -p 14556:14556/udp --name=px4-ros px4io/px4-dev-ros bash
#xhost +local:`docker ps -aqf "name=^/px4-ros$"`
#docker start px4-ros 
#docker attach px4-ros 
