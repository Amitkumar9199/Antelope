`Dockerfile` - docker container with bcc support

`docker-compose.yml` - Docker compose file

`Build docker` - `sudo docker build -t bcc-docker .`

`build_network.sh` -  bash script to create a 6node (h1-4, s1,s2) with dumbbell topology having the following edges.H1-s1, h2-s1, s1-s2, s2-h3, s2-h4. S1 and s2 are routers.All the nodes are instances of bcc-container.

`delete_network.sh` - to remove the topology and docker containers

`entrypoint.sh` - file used by Dockerfile for `CMD`.

`hello.py` - file used by Dockerfile - BCC Hello_world program

`hello_world.py` - file used by Dockerfile - BCC Hello_world program


Setup:


h1(192.168.10.2,eth0)     - (192.168.10.1,eth0)s1(eth2) - (eth2)s2(eth0,192.168.12.1) - (192.168.12.2,eth0)h3   

h2(192.168.11.2,eth0)     - (192.168.11.1,eth1)s1(eth2) - (eth2)s2(eth1,192.168.13.1) - (192.168.13.2,eth0)h4

h5(192.168.15.2,eth0)     - (192.168.15.1,eth3)s1(eth2) - (eth2)s2(eth3,192.168.16.1) -  (192.168.16.2,eth0)h6

