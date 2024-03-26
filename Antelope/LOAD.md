# Loading the sockops function
This document describes the steps required in loading the functions in the
sockops section.
Earlier, the loadsockops program was used in kernel versions < 5.0. Since it
has now become obsolete we have switched to the bpftool mechanism for loading
the program responsible for actually switching the tcp congestion control
algorithm. 

## Steps with bpftool
1. The repositories bpf-developer-tools and ebpf-sockops were referred to for generating the scripts
   for loading and unloading the program using bpftool. 
2. We must first mount the bpf filesystem where the bpf-maps as well as the bpf
   programs shall be stored.
3. Compile the programs using the clang tool with the bpf target flag set so
   that it compiles without any errors.
4. Once done, use the bpftool prog load to load in the tcp_change_cc file and
   begin its execution. All this is done by the load.sh script. Executing make
   and then ./load.sh would load the sockops program
5. You shall be able to see the outputs using trace.sh
   file which basically opens the tracing_pipe file

## How is the shared memory for communicating between transfer_cc and tcp_change_cc handled?
Originally, the load_sock_ops function used shared memory for communicating
between the sockops program and other programs. 
Bpftools eases this process by providing with bpf_helper functions and
bpf__obj_get() function. Using this function, we can directly access the pinned
maps(cong_map and ip_cong_map are pinned in their declaration itself in
tcp_changecc_kern.c to the /sys/fs/bpf mount point)
The bpf__obj_get() function returns the respective file descriptors for both
maps which can directly be used in the bpf_map_update_elem() or similar bpf
helper functions to update the contents of the map, which can then be accessed
by the tcp_changecc_kern function.

## Steps to test using namespace 
1. First execute the setup.sh to set up the required namespaces with two hosts
   connected to a single switch,
2. Once done, we can test it using the bash-h1.sh and bash-h2.sh scripts which
   in turn send a test file between the two hosts to check the connectivity
3. Use sudo ip netns exec h1 bash to open a bash terminal specific to the h1
   host or h2 bash for the h2 host, once the previous commands execute without
   any errors.
