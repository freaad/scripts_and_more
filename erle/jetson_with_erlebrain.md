# Using NVIDIA Jetons TX1/TX2 as a companion computer with Erle Brain 3
This document describes how to connect Jetson TX1/2 board to Erle Brain 3 (EB3). In this configuraiton, EB3 is used to run MAVROS only to control a vehicle (e.g. rover), the rest of tne nodes are running on Jetson and ground control station (laptop).

## Connecting Jetson and Erle Brain
There are 2 ways to connect Jetson and EB3:
1. Connect Jetson and EB3 using Ethernet protocol. This is a more secure/reliable/faster method and should be default option.
2. Connect Jetson to EB3 WiFi access point (AP). This is a less secure/reliable method. For example, it might be used in case Jetson carrier board does not have Ethernet port. This method also allows to keep Jetson WiFi AP intact and connect to the Jetson via WiFi if needed.

### Connecting Jetson and EB3 using Ethernet
1. Connect Jetson carrier board and EB3 using ordinary Ethernet cable (note: you do NOT need to use crossover cable, it's a thing from the past).
2. Login/SSH to Jetson and change IPv4 Settings for the Ethernet connection. You need to set Method property to Shared. This can be done either in GUI or via command line:
    ```nmcli connection modify "Wired connection 1" ipv4.method shared```
Then restart or wait a little bit.
3.  Verify that Jetson and EB3 are connected by running `ifconfig` and checking that Ethernet interface has proper IPv4 address. For Jetson board the address should be something like `10.42.1.1`, on EB3 side it will be something like `10.42.1.86`. As an additional check, make sure you can ping Jetson from EB3 and vice versa.

#### Configuring network routing between different clients
In case there are more nodes than just Jetson and EB3 **and** nodes that connect on **different** NICs need to communicate with each other (publish/subscribe), there is additional step that needs to be done: network routing setup. One example of such configuration can be Jetson running a ROS node that is subsribed to a topic published by another ROS node running on GCS (laptop). In such scenario, Jetson and GCS will be on different networks (Ethernet vs. WiFi) so proper routing is needed.

**Note**: if you just have Jetson + EB3, this step is not required.

Before making static changes to a Linux network configuration, it is a good idea to test everything by using dynamic configuration. If something does not work, rebooting will restore the previous configuration.
##### Dynamic configuration
1. Check that IP4 forwarding is enabled on EB3: `sudo sysctl net.ipv4.ip_forward` Enable if needed by running this command: `sudo sysctl -w net.ipv4.ip_forward=1` 
2. Check the IP addresses of EB3, Jetson and GCS. It might be something like `10.42.1.1` for Jetson, `10.0.0.2` for GCS and 2 addresses on EB3: `10.0.0.1` for WiFi interface and `10.42.1.86` for Ethernet. You can further verify that you cannot ping GCS from Jetson: `10.0.0.2` (`connect: Network is unreachable`) and vice versa.
3. Setup routing on Jetson to GCS via EB3 Ethernet NIC: `sudo ip route add 10.0.0.0/24 via 10.42.1.86`.
4. Setup routing on GCS to Jetson via EB3 WiFi NIC: `sudo ip route add 10.42.1.0/24 via 10.0.0.1`
5. Now check that everything is working by pinging Jetson from GCS and vice versa.
**Note**: your Jetson IP addresses can be different, double check by running `ifconfig`

### Connecting Jetson to EB WiFi AP
Connect Jetson to EB3 WiFi AP. You can make the Jetson to connect automatically by modifying network interface file (google for more info).
Note that by default EB3 allows only one client, if you need more than modify DNS Masquerading configuration file located at `/etc/dnsmasq.conf`. Refer to [DNSMASQ](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) documentation for more details.

## Running ROS nodes
1. Set the ROS master env variable on every machine except EB3, using appropriate IP. For example, on Jetson it can be: `export ROS_MASTER_URI=http://10.42.1.86:11311` while on GCS: `export ROS_MASTER_URI=http://10.0.0.1:11311`
2. Set `ROS_IP` env variable on every client including EB3, using appropriate IP. For example, on Jetson it can be: `export ROS_IP=10.42.1.1` while on GCS: `export ROS_IP=10.0.0.2`.
3. Restart ROS and MAVROS. Since our setup requires only MAVROS, below are the commands to restart MAVROS:
```
sudo systemctl stop mavros.service
sudo systemctl stop ros.service
roscore &
rosrun mavros mavros_node _fcu_url:="udp://:6001@" _gcs_url:="udp://10.0.0.1:9000@10.0.0.2:6000?ids=1,255,252"
```
3. Verify that messages can be propagated between the clients by running `rostopic list` and then `rostopic echo /mavros/state`. If everything is setup correctly, the first command should display list of topics, while the second - start producing MAVROS state in the console. If you don't see any output from the second command - check your IP addresses and routing again.
4. Optional: in case you have more than just Jetson (e.g. GCS) that require message exchange, verify that it works. For exampple, if GCS is runnin joystick node with topic `/joy` that is subscribed to a client running on Jetson, verify that Jetson can receive messages by running the following on Jetson: `rostopic echo /joy`

That's it for now.