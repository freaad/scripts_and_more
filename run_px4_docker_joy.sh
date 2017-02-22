# docker run -it --privileged -v /data/:/data/:rw -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY --network=host --name=px4-ros-joy px4io/px4-dev-ros bash
xhost +local:`docker ps -aqf "name=px4-ros-joy"`
docker start px4-ros-joy
docker attach px4-ros-joy
