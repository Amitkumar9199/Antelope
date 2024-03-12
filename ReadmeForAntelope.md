# Antelope
## A. Initial setup
### Directory Structure
List of relevant folders
```
~(Home)
├── bcc_python_dev
├── docker_2
└── GIT
    └── Antelope
    ├── bpftool
    ├── ebpf-hello-world
    ├── bcc
    ├── easy-grub-selector
    └── linux-5.15.148
```

### 1. Clone repository
**Note:** Create own github repository and add instructions here.
### 2. Customize Linux kernel
Before you begin with execution of antelope, you will have to recompile the
linux kernel on your system with the file modifications mentioned below.
The instructions have been written for kernel modifications on the Ubuntu OS.
In case you are using any other OS, please refer to the instructions to compile
the kernel on the required OS.
#### i. Download Kernel Sources:
You need to first download the linux kernel file using the following link - 
```bash
mkdir custom-kernel && cd custom-kernel/
wget https://cdn.kernel.org/pub/linux/kernel/vA.x/linux-A.B.C.tar.xz
tar -xvf linux-A.B.C.tar.xz
```
where A, B, C refer to the version number that you wish to download. These
instructions work only on Ubuntu Distros having version > 20.04, and kernel
versions > 5.15. Please be sure to download the kernel version accordingly.
We use kernel **5.15.148** for compilation on a **22.04 Ubuntu** setup.

#### ii. Dependency resolution for Kernel compilation:
Next download the required dependencies for kernel compilation - 
```bash
sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison
```
#### iii. Modify kernel sources:
Once all the dependencies have been installed, modify the kernel source files as per the following instructions

* **include/uapi/linux/bpf.h**  <a name="bpf_h"><br></a>
The following lines need to be added in the **include/uapi/linux/bpf.h** file in the kernel folder containing all the `bpf_sock_ops` enum entries. Open the file using
```bash
cd linux-A.B.C/
nano include/uapi/linux/bpf.h
```

- Search for `bpf_sock_ops` and look for an **enum** containing `BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB` variable. Add the new enum variables as listed below.
- You can refer to the **kernel_files/bpf.h** file in this repository as an example.
```c
...
//Inside bpf.h file
BPF_SOCK_OPS_TCP_ACK_CB,
BPF_SOCK_OPS_TCL_CLOSE_CB,
BPF_BBR_ENTER,
...
```
* **net/ipv4/tcp.c** <br>
Next, open the **net/ipv4/tcp.c** file in the kernel folder.
```bash
nano net/ipv4/tcp.c
```

- Add the following lines by searching for the functions mentioned in the following comments and adding it inside those.
- You can use the **kernel_files/tcp.c** file as a reference - 
```c
// Inside the tcp_sendmsg() function
tcp_call_bpf(sk, BPF_SOCK_OPS_TCP_ACK_CB, 0, NULL);
// Inside the tcp_close_state() function
tcp_call_bpf(sk, BPF_SOCK_OPS_TCL_CLOSE_CB, 0, NULL);
```
* Enable BPF in kernel configuration parameters: <br>
You can also copy the `.config` file present in the folder to apply the same configuration for your kernel as well - 
```bash
cp ~/project_antelope/antelope/kernel_files/config ~/project_antelope/custom-kernel/linux-A.B.C/.config
```
### 3. Compile customized Linux kernel and install it
Once all the changes are made, execute the following in order to compile and
install the kernel.
```bash
make -j$(nproc)
sudo make modules_install
sudo make headers_install
sudo make install
sudo update-grub
```
Reboot your system to see the newly installed kernel. You can select the newly
installed kernel version on your grub screen.

In case your grub screen is not
visible(happens generally when the system is not dual booted), you can add the
following changes in your /etc/default/grub file.
```bash
nano /etc/default/grub
```
Modify the file as follows
```diff
< GRUB_TIMEOUT=0
...
> GRUB_TIMEOUT=10
...
< GRUB_TIMEOUT_STYLE=hidden
...
> GRUB_TIMEOUT_STYLE=menu
...

```
Run ```sudo update-grub```  to apply the changes and **reboot** the system.
**Note:** You can use a small tool [easy-grub-selector](https://github.com/subhrendu1987/easy-grub-selctor) to select the custom build kernel and update the grub with it.

### 4. Changes after reboot:
After rebooting, the **/usr/include/linux/bpf.h** needs to be updated with the same kernel variables (as mentioned in [**include/uapi/linux/bpf.h**](#bpf_h)).
```bash
nano /usr/include/linux/bpf.h
```
* Add the changes similar to the linux kernel file
```c
...
BPF_SOCK_OPS_TCP_ACK_CB,
BPF_SOCK_OPS_TCL_CLOSE_CB,
BPF_BBR_ENTER,
...
```

### 5. Install `bcc` in your system
* Install the following dependencies for `bcc`
```bash
sudo apt-get install bpfcc-tools zip bison build-essential cmake flex git libedit-dev \
  libllvm14 llvm-14-dev libclang-14-dev python3 zlib1g-dev libelf-dev libfl-dev python3-setuptools \
  liblzma-dev libdebuginfod-dev arping netperf iperf
```

* Once the dependencies are successfully installed, you can follow these
instructions to install `bcc`
```bash
cd ~/GIT
git clone https://github.com/iovisor/bcc.git bcc
mkdir bcc/build; cd bcc/build
cmake ..
make
sudo make install
cmake -DPYTHON_CMD=python3 .. # build python3 binding
pushd src/python/
make
sudo make install
popd
```
You can also follow the bcc installation instructions at [https://github.com/iovisor/bcc/blob/master/INSTALL.md](https://github.com/iovisor/bcc/blob/master/INSTALL.md)
* To test the bcc installation create a `hello.py` file and execute it.
  ```python
   #!/usr/bin/python3  
  from bcc import BPF
  
  program = r"""
  int hello(void *ctx) {
      bpf_trace_printk("Hello World!");
      return 0;
  }
  """
  
  b = BPF(text=program)
  syscall = b.get_syscall_fnname("execve")
  b.attach_kprobe(event=syscall, fn_name="hello")
  
  b.trace_print()
  ```
- To execute use `sudo ./hello.py`

### 5. Installing `bpftool`
* To install `bpftools` - 
```bash
cd ~/GIT
git clone --recurse-submodules https://github.com/libbpf/bpftool.git
cd bpftool/src/
make
make install
```
* <span style="color:red;"> How to test `bpftools`? </span>

### 6. Resolve Python dependencies
Install all the required python libraries using
```bash
cd ~/GIT/Antelope/
sudo apt-get install python3 pip3
pip3 install -r requirements.txt
```

## B. Execute Basic Antelope
To begin execution - 
```bash
cd ~/GIT/Antelope
make clean
mkdir /tmp/cgroupv2
sudo mount -t cgroup2 none /tmp/cgroupv2
sudo mkdir -p /tmp/cgroupv2/foo
sudo echo $$ >> /tmp/cgroupv2/foo/cgroup.procs
make
./load.sh
sudo python3 recvAndSetCC.py
```

To see the output of the bpf program execute - 
```bash
./trace.sh
```

To unload the attached program run - 
```bash 
./unload.sh
```
