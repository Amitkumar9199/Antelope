# Use Ubuntu 22.04 (Jammy) as the base image
FROM ubuntu:22.04

# Update package lists and install necessary dependencies
RUN apt-get update && \
    apt-get install -y zip bison build-essential cmake flex git libedit-dev \
                       libllvm14 llvm-14-dev libclang-14-dev python3 zlib1g-dev \
                       libelf-dev libfl-dev python3-setuptools liblzma-dev \
                       libdebuginfod-dev arping netperf iperf  \
                       luajit luajit-5.1-dev

RUN apt-get install -y wget nano tree iputils-ping iproute2 net-tools 

RUN apt-get install -y linux-headers-$(uname -r)

RUN apt-get install -y sudo file

# # Set the download URL for libpolly .deb file
# ARG LIBPOLLY_DEB_URL=https://apt.llvm.org/focal/pool/main/l/llvm-toolchain-14/libpolly-14-dev_14.0.6~%2B%2B20230131082221%2Bf28c006a5895-1~exp1~20230131082248.184_amd64.deb

# # Download libpolly .deb file using wget
# RUN wget -qO /tmp/libpolly.deb ${LIBPOLLY_DEB_URL}

# # Install libpolly .deb file using dpkg
# RUN dpkg -i /tmp/libpolly.deb

# # Cleanup downloaded .deb file
# RUN rm /tmp/libpolly.deb


# Clone BCC repository and build
RUN git clone https://github.com/iovisor/bcc.git && \
    cd bcc && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    cmake -DPYTHON_CMD=python3 .. && \
    cd src/python/ && \
    make && \
    make install && \
    cd ../..

# Clean up unnecessary packages and files
RUN apt-get autoremove -y && \
    apt-get clean

# RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /bcc

# Set environment variables
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"


# Add a script to mount tracefs and execute your Python script
COPY entrypoint.sh /home/entrypoint.sh
COPY hello_world.py /home/hello_world.py
COPY hello.py /home/hello.py

RUN chmod +x /home/entrypoint.sh

# Default command
# CMD ["/bin/bash"]
CMD ["/home/entrypoint.sh"]

# sudo docker build -t bcc-docker .
# sudo docker run -it --privileged  bcc-docker
# 
