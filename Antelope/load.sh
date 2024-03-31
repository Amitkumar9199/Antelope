#!/bin/bash

set -x
set -e 
mount -t bpf bpf /sys/fs/bpf/
if [ -e "/sys/fs/bpf/bpf_sockops" ]; then
echo ">>> bpf_sockops already loaded, uninstalling..."
./unload.sh
echo ">>> old program already deleted..."
fi

bpftool prog load tcp_changecc_kern.o /sys/fs/bpf/tcp_changecc type sockops 
bpftool cgroup attach "/sys/fs/cgroup/" sock_ops pinned "/sys/fs/bpf/tcp_changecc"

