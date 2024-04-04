# https://pancho.dev/posts/linux-router-with-containers/

# Create 4 nodes and 2 routers

chmod +x build_image.sh
./build_image.sh

docker run --privileged -d -t --net none --name h1 bcc-h1 bash
docker run --privileged -d -t --net none --name h2 bcc-h2 bash
docker run --privileged -d -t --net none --name h3 bcc-h3 bash
docker run --privileged -d -t --net none --name h4 bcc-h4 bash
docker run --privileged -d -t --net none --name h5 bcc-h5 bash
docker run --privileged -d -t --net none --name h6 bcc-h6 bash
docker run --privileged -d -t --net none --name s1 bcc-s1 bash
docker run --privileged -d -t --net none --name s2 bcc-s2 bash

h1_id=$(docker ps --format '{{.ID}}' --filter name=h1)
h2_id=$(docker ps --format '{{.ID}}' --filter name=h2)
h3_id=$(docker ps --format '{{.ID}}' --filter name=h3)
h4_id=$(docker ps --format '{{.ID}}' --filter name=h4)
h5_id=$(docker ps --format '{{.ID}}' --filter name=h5)
h6_id=$(docker ps --format '{{.ID}}' --filter name=h6)
s1_id=$(docker ps --format '{{.ID}}' --filter name=s1)
s2_id=$(docker ps --format '{{.ID}}' --filter name=s2)

h1_pid=$(docker inspect -f '{{.State.Pid}}' ${h1_id})
h2_pid=$(docker inspect -f '{{.State.Pid}}' ${h2_id})
h3_pid=$(docker inspect -f '{{.State.Pid}}' ${h3_id})
h4_pid=$(docker inspect -f '{{.State.Pid}}' ${h4_id})
h5_pid=$(docker inspect -f '{{.State.Pid}}' ${h5_id})
h6_pid=$(docker inspect -f '{{.State.Pid}}' ${h6_id})
s1_pid=$(docker inspect -f '{{.State.Pid}}' ${s1_id})
s2_pid=$(docker inspect -f '{{.State.Pid}}' ${s2_id})

mkdir -p /var/run/netns/

ln -sfT /proc/$h1_pid/ns/net /var/run/netns/$h1_id
ln -sfT /proc/$h2_pid/ns/net /var/run/netns/$h2_id
ln -sfT /proc/$h3_pid/ns/net /var/run/netns/$h3_id
ln -sfT /proc/$h4_pid/ns/net /var/run/netns/$h4_id
ln -sfT /proc/$h5_pid/ns/net /var/run/netns/$h5_id
ln -sfT /proc/$h6_pid/ns/net /var/run/netns/$h6_id
ln -sfT /proc/$s1_pid/ns/net /var/run/netns/$s1_id
ln -sfT /proc/$s2_pid/ns/net /var/run/netns/$s2_id

# Create the virtual ethernet devices for conecting H1 and S1
ip link add 'h1-eth0' type veth peer name 's1-eth0'
ip link add 'h2-eth0' type veth peer name 's1-eth1'
ip link add 'h3-eth0' type veth peer name 's2-eth0'
ip link add 'h4-eth0' type veth peer name 's2-eth1'
ip link add 'h5-eth0' type veth peer name 's1-eth3'
ip link add 'h6-eth0' type veth peer name 's2-eth3'

# Create the virtual ethernet devices for conecting S1 and S2
ip link add 's1-eth2' type veth peer name 's2-eth2'

# Attach the virtual ethernet devices to the network namespaces

ip link set 'h1-eth0' netns $h1_id
ip link set 'h2-eth0' netns $h2_id
ip link set 'h5-eth0' netns $h5_id
ip link set 's1-eth0' netns $s1_id
ip link set 's1-eth1' netns $s1_id
ip link set 's1-eth2' netns $s1_id
ip link set 's1-eth3' netns $s1_id

ip link set 'h3-eth0' netns $h3_id
ip link set 'h4-eth0' netns $h4_id
ip link set 'h6-eth0' netns $h6_id
ip link set 's2-eth0' netns $s2_id
ip link set 's2-eth1' netns $s2_id
ip link set 's2-eth2' netns $s2_id
ip link set 's2-eth3' netns $s2_id

# rename h1 container interface from h1-eth0 to eth0
ip netns exec $h1_id ip link set 'h1-eth0' name 'eth0'
ip netns exec $h2_id ip link set 'h2-eth0' name 'eth0'
ip netns exec $h3_id ip link set 'h3-eth0' name 'eth0'
ip netns exec $h4_id ip link set 'h4-eth0' name 'eth0'
ip netns exec $h5_id ip link set 'h5-eth0' name 'eth0'
ip netns exec $h6_id ip link set 'h6-eth0' name 'eth0'

# rename s1 container interface from s1-eth0 to eth0
ip netns exec $s1_id ip link set 's1-eth0' name 'eth0'
ip netns exec $s1_id ip link set 's1-eth1' name 'eth1'
ip netns exec $s1_id ip link set 's1-eth2' name 'eth2'
ip netns exec $s1_id ip link set 's1-eth3' name 'eth3'

# rename s2 container interface from s2-eth0 to eth0
ip netns exec $s2_id ip link set 's2-eth0' name 'eth0'
ip netns exec $s2_id ip link set 's2-eth1' name 'eth1'
ip netns exec $s2_id ip link set 's2-eth2' name 'eth2'
ip netns exec $s2_id ip link set 's2-eth3' name 'eth3'

# Set the interfaces up
ip netns exec $h1_id ip link set 'eth0' up
ip netns exec $h1_id ip link set 'lo' up
ip netns exec $h2_id ip link set 'eth0' up
ip netns exec $h2_id ip link set 'lo' up
ip netns exec $h3_id ip link set 'eth0' up
ip netns exec $h3_id ip link set 'lo' up
ip netns exec $h4_id ip link set 'eth0' up
ip netns exec $h4_id ip link set 'lo' up
ip netns exec $h5_id ip link set 'eth0' up
ip netns exec $h5_id ip link set 'lo' up
ip netns exec $h6_id ip link set 'eth0' up
ip netns exec $h6_id ip link set 'lo' up

ip netns exec $s1_id ip link set 'eth0' up
ip netns exec $s1_id ip link set 'eth1' up
ip netns exec $s1_id ip link set 'eth2' up
ip netns exec $s1_id ip link set 'eth3' up
ip netns exec $s1_id ip link set 'lo' up

ip netns exec $s2_id ip link set 'eth0' up
ip netns exec $s2_id ip link set 'eth1' up
ip netns exec $s2_id ip link set 'eth2' up
ip netns exec $s2_id ip link set 'eth3' up
ip netns exec $s2_id ip link set 'lo' up

# Set the IP addresses
ip netns exec $h1_id ip addr add 192.168.10.2/24 dev eth0
ip netns exec $h2_id ip addr add 192.168.11.2/24 dev eth0
ip netns exec $h5_id ip addr add 192.168.15.2/24 dev eth0

ip netns exec $s1_id ip addr add 192.168.10.1/24 dev eth0
ip netns exec $s1_id ip addr add 192.168.11.1/24 dev eth1
ip netns exec $s1_id ip addr add 192.168.12.1/24 dev eth2
ip netns exec $s1_id ip addr add 192.168.15.1/24 dev eth3

ip netns exec $s2_id ip addr add 192.168.13.1/24 dev eth0
ip netns exec $s2_id ip addr add 192.168.14.1/24 dev eth1
ip netns exec $s2_id ip addr add 192.168.12.2/24 dev eth2
ip netns exec $s2_id ip addr add 192.168.16.1/24 dev eth3

ip netns exec $h3_id ip addr add 192.168.13.2/24 dev eth0
ip netns exec $h4_id ip addr add 192.168.14.2/24 dev eth0
ip netns exec $h6_id ip addr add 192.168.16.2/24 dev eth0
#
# # set default gw on h1 container
ip netns exec $h1_id ip route add default via 192.168.10.1 dev eth0
ip netns exec $h2_id ip route add default via 192.168.11.1 dev eth0
ip netns exec $h3_id ip route add default via 192.168.13.1 dev eth0
ip netns exec $h4_id ip route add default via 192.168.14.1 dev eth0
ip netns exec $h5_id ip route add default via 192.168.15.1 dev eth0
ip netns exec $h6_id ip route add default via 192.168.16.1 dev eth0

# add a route to the router for the 192.168.10.1/24 network
ip netns exec $s1_id ip route add 192.168.10.2 via 192.168.10.1 dev eth0
ip netns exec $s1_id ip route add 192.168.11.2 via 192.168.11.1 dev eth1
ip netns exec $s1_id ip route add 192.168.15.2 via 192.168.15.1 dev eth3

ip netns exec $s2_id ip route add 192.168.13.2 via 192.168.13.1 dev eth0
ip netns exec $s2_id ip route add 192.168.14.2 via 192.168.14.1 dev eth1
ip netns exec $s2_id ip route add 192.168.16.2 via 192.168.16.1 dev eth3

ip netns exec $s1_id ip route add default via 192.168.12.2 dev eth2
ip netns exec $s2_id ip route add default via 192.168.12.1 dev eth2

ip netns exec $s1_id sysctl -w net.ipv4.ip_forward=1
ip netns exec $s2_id sysctl -w net.ipv4.ip_forward=1

sysctl -w net.ipv4.ip_forward=1

# test the connection using the following command
# docker exec -it h1 ping -c 4 192.168.11.1

# to open container in interactive mode
#  docker exec -it h1 bash

# In the sender container
# cat /path/to/your/file | nc -w 3 192.168.13.2 12345

# In the receiver container
# nc -l -p 12345 > received_file

# Cleanup
# docker stop h1 h2 h3 h4 s1 s2
# docker rm h1 h2 h3 h4 s1 s2

# Clean up the Network namespaces links
# rm -rf /var/run/netns/

