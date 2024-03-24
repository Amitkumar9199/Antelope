# this script is used to build the docker image

# build using file Dockerfile-h1
sudo docker build -t bcc-h1 -f Dockerfile-h1 .
sudo docker build -t bcc-h2 -f Dockerfile-h2 .
sudo docker build -t bcc-h3 -f Dockerfile-h3 .
sudo docker build -t bcc-h4 -f Dockerfile-h4 .
sudo docker build -t bcc-s1 -f Dockerfile-s1 .
sudo docker build -t bcc-s2 -f Dockerfile-s2 .

