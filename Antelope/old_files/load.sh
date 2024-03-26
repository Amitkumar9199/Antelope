#!/bin/bash

set -x
set -e 
sudo mount -t bpf bpf /sys/fs/bpf/
if [ -e "/sys/fs/bpf/bpf_sockops" ]; then
echo ">>> bpf_sockops already loaded, uninstalling..."
./unload.sh
echo ">>> old program already deleted..."
fi

sudo bpftool prog load tcp_changecc_kern.o /sys/fs/bpf/tcp_changecc type sockops 
sudo bpftool cgroup attach "/sys/fs/cgroup/" sock_ops pinned "/sys/fs/bpf/tcp_changecc"

