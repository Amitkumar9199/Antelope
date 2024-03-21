# https://pancho.dev/posts/linux-router-with-containers/

# Create 4 nodes and 2 routers

docker run --privileged -d -t --net none --name h1 bcc-docker bash
docker run --privileged -d -t --net none --name h2 bcc-docker bash
docker run --privileged -d -t --net none --name h3 bcc-docker bash
docker run --privileged -d -t --net none --name h4 bcc-docker bash
docker run --privileged -d -t --net none --name s1 bcc-docker bash
docker run --privileged -d -t --net none --name s2 bcc-docker bash

h1_id=$(docker ps --format '{{.ID}}' --filter name=h1)
h2_id=$(docker ps --format '{{.ID}}' --filter name=h2)
h3_id=$(docker ps --format '{{.ID}}' --filter name=h3)
h4_id=$(docker ps --format '{{.ID}}' --filter name=h4)
s1_id=$(docker ps --format '{{.ID}}' --filter name=s1)
s2_id=$(docker ps --format '{{.ID}}' --filter name=s2)

h1_pid=$(docker inspect -f '{{.State.Pid}}' ${h1_id})
h2_pid=$(docker inspect -f '{{.State.Pid}}' ${h2_id})
h3_pid=$(docker inspect -f '{{.State.Pid}}' ${h3_id})
h4_pid=$(docker inspect -f '{{.State.Pid}}' ${h4_id})
s1_pid=$(docker inspect -f '{{.State.Pid}}' ${s1_id})
s2_pid=$(docker inspect -f '{{.State.Pid}}' ${s2_id})

mkdir -p /var/run/netns/

ln -sfT /proc/$h1_pid/ns/net /var/run/netns/$h1_id
ln -sfT /proc/$h2_pid/ns/net /var/run/netns/$h2_id
ln -sfT /proc/$h3_pid/ns/net /var/run/netns/$h3_id
ln -sfT /proc/$h4_pid/ns/net /var/run/netns/$h4_id
ln -sfT /proc/$s1_pid/ns/net /var/run/netns/$s1_id
ln -sfT /proc/$s2_pid/ns/net /var/run/netns/$s2_id

# Create the virtual ethernet devices for conecting H1 and S1
ip link add 'h1-eth0' type veth peer name 's1-eth0'
ip link add 'h2-eth0' type veth peer name 's1-eth1'
ip link add 'h3-eth0' type veth peer name 's2-eth0'
ip link add 'h4-eth0' type veth peer name 's2-eth1'

# Create the virtual ethernet devices for conecting S1 and S2
ip link add 's1-eth2' type veth peer name 's2-eth2'

# Attach the virtual ethernet devices to the network namespaces

ip link set 'h1-eth0' netns $h1_id
ip link set 'h2-eth0' netns $h2_id
ip link set 's1-eth0' netns $s1_id
ip link set 's1-eth1' netns $s1_id
ip link set 's1-eth2' netns $s1_id

ip link set 'h3-eth0' netns $h3_id
ip link set 'h4-eth0' netns $h4_id
ip link set 's2-eth0' netns $s2_id
ip link set 's2-eth1' netns $s2_id
ip link set 's2-eth2' netns $s2_id

# rename h1 container interface from h1-eth0 to eth0
ip netns exec $h1_id ip link set 'h1-eth0' name 'eth0'
ip netns exec $h2_id ip link set 'h2-eth0' name 'eth0'
ip netns exec $h3_id ip link set 'h3-eth0' name 'eth0'
ip netns exec $h4_id ip link set 'h4-eth0' name 'eth0'

# rename s1 container interface from s1-eth0 to eth0
ip netns exec $s1_id ip link set 's1-eth0' name 'eth0'
ip netns exec $s1_id ip link set 's1-eth1' name 'eth1'
ip netns exec $s1_id ip link set 's1-eth2' name 'eth2'

# rename s2 container interface from s2-eth0 to eth0
ip netns exec $s2_id ip link set 's2-eth0' name 'eth0'
ip netns exec $s2_id ip link set 's2-eth1' name 'eth1'
ip netns exec $s2_id ip link set 's2-eth2' name 'eth2'

# Set the interfaces up
ip netns exec $h1_id ip link set 'eth0' up
ip netns exec $h1_id ip link set 'lo' up
ip netns exec $h2_id ip link set 'eth0' up
ip netns exec $h2_id ip link set 'lo' up
ip netns exec $h3_id ip link set 'eth0' up
ip netns exec $h3_id ip link set 'lo' up
ip netns exec $h4_id ip link set 'eth0' up
ip netns exec $h4_id ip link set 'lo' up

ip netns exec $s1_id ip link set 'eth0' up
ip netns exec $s1_id ip link set 'eth1' up
ip netns exec $s1_id ip link set 'eth2' up
ip netns exec $s1_id ip link set 'lo' up

ip netns exec $s2_id ip link set 'eth0' up
ip netns exec $s2_id ip link set 'eth1' up
ip netns exec $s2_id ip link set 'eth2' up
ip netns exec $s2_id ip link set 'lo' up

# Set the IP addresses
ip netns exec $h1_id ip addr add 192.168.10.2/24 dev eth0
ip netns exec $h2_id ip addr add 192.168.11.2/24 dev eth0

ip netns exec $s1_id ip addr add 192.168.10.1/24 dev eth0
ip netns exec $s1_id ip addr add 192.168.11.1/24 dev eth1
ip netns exec $s1_id ip addr add 192.168.12.1/24 dev eth2

ip netns exec $s2_id ip addr add 192.168.13.1/24 dev eth0
ip netns exec $s2_id ip addr add 192.168.14.1/24 dev eth1
ip netns exec $s2_id ip addr add 192.168.12.2/24 dev eth2

ip netns exec $h3_id ip addr add 192.168.13.2/24 dev eth0
ip netns exec $h4_id ip addr add 192.168.14.2/24 dev eth0
#
# # set default gw on h1 container
ip netns exec $h1_id ip route add default via 192.168.10.1 dev eth0
ip netns exec $h2_id ip route add default via 192.168.11.1 dev eth0
ip netns exec $h3_id ip route add default via 192.168.13.1 dev eth0
ip netns exec $h4_id ip route add default via 192.168.14.1 dev eth0

# add a route to the router for the 192.168.10.1/24 network
ip netns exec $s1_id ip route add 192.168.10.2 via 192.168.10.1 dev eth0
ip netns exec $s1_id ip route add 192.168.11.2 via 192.168.11.1 dev eth1

ip netns exec $s2_id ip route add 192.168.13.2 via 192.168.13.1 dev eth0
ip netns exec $s2_id ip route add 192.168.14.2 via 192.168.14.1 dev eth1

ip netns exec $s1_id ip route add default via 192.168.12.2 dev eth2
ip netns exec $s2_id ip route add default via 192.168.12.1 dev eth2

ip netns exec $s1_id sysctl -w net.ipv4.ip_forward=1
ip netns exec $s2_id sysctl -w net.ipv4.ip_forward=1

sysctl -w net.ipv4.ip_forward=1

# test the connection using the following command
# docker exec -it h1 ping -c 4 192.168.11.1

# Install OpenSSH server
# ip netns exec $h1_id apt-get update
# ip netns exec $h1_id apt-get install -y openssh-server

# Install OpenSSH server in h1
# docker exec -it h1 apt-get update
# docker exec -it h1 apt-get install -y openssh-server

# Create the SFTP user's directory and set proper ownership
docker exec -it h1 mkdir -p /home/sftpuser
docker exec -it h1 useradd -d /home/sftpuser -s /usr/sbin/nologin sftpuser
docker exec -it h1 chown sftpuser:sftpuser /home/sftpuser

# Set a password for the sftpuser (you will be prompted to enter the password)
docker exec -it h1 passwd sftpuser

# if sshd_config file exists, rename it to sshd_config.old
docker exec -it h1 bash -c "mv /etc/ssh/sshd_config /etc/ssh/sshd_config.old"

# if sshd_config file does not exist, create it
docker exec -it h1 bash -c "touch /etc/ssh/sshd_config"

# Configure SSHD for SFTP
docker exec -it h1 bash -c "echo 'Subsystem sftp internal-sftp' >> /etc/ssh/sshd_config"
docker exec -it h1 bash -c "echo 'Match User sftpuser' >> /etc/ssh/sshd_config"
docker exec -it h1 bash -c "echo 'ChrootDirectory /home/sftpuser' >> /etc/ssh/sshd_config"
docker exec -it h1 bash -c "echo 'ForceCommand internal-sftp' >> /etc/ssh/sshd_config"
docker exec -it h1 bash -c "echo 'AllowTcpForwarding no' >> /etc/ssh/sshd_config"
docker exec -it h1 bash -c "echo 'X11Forwarding no' >> /etc/ssh/sshd_config"

# Restart SSH service to apply changes
docker exec -it h1 service ssh restart


# Example command to use SFTP from h2 to connect to h1
# Replace 'your_password' with the actual password of the sftpuser
docker exec -it h2 sftp sftpuser@192.168.10.2

# ./sftp_server_setup.sh $h1_id
# ./sftp_client_connect.sh $h2_id 192.168.10.2 sftpuser

# Cleanup
# docker stop h1 h2 h3 h4 s1 s2
# docker rm h1 h2 h3 h4 s1 s2

# Clean up the Network namespaces links
# rm -rf /var/run/netns/

