set -x
sudo bpftool cgroup detach "/sys/fs/cgroup/" sock_ops pinned "/sys/fs/bpf/tcp_changecc" && \
sudo unlink /sys/fs/bpf/tcp_changecc
