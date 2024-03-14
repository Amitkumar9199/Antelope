`Dockerfile` - docker container with bcc support

`docker-compose.yml` - Docker compose file

`Build docker` - `sudo docker build -t bcc-docker .`

`build_network.sh` -  bash script to create a 6node (h1-4, s1,s2) with dumbbell topology having the following edges.H1-s1, h2-s1, s1-s2, s2-h3, s2-h4. S1 and s2 are routers.All the nodes are instances of bcc-container.

`delete_network.sh` - to remove the topology and docker containers

`entrypoint.sh` - file used by Dockerfile for `CMD`.

`hello.py` - file used by Dockerfile - BCC Hello_world program

`hello_world.py` - file used by Dockerfile - BCC Hello_world program
