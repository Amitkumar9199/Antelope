from bcc import BPF

# Define the eBPF program
prog = """
int hello_world(void *ctx) {
    bpf_trace_printk("Hello, World!\\n");
    return 0;
}
"""

# Load eBPF program
b = BPF(text=prog)

# Attempt to attach eBPF program to a more common kernel function
try:
    b.attach_kprobe(event="__x64_sys_clone", fn_name="hello_world")
    print("Attached to __x64_sys_clone.")
except Exception as e:
    print(f"Failed to attach to __x64_sys_clone: {e}")

print("eBPF program loaded. Check the output with 'sudo cat /sys/kernel/tracing/trace_pipe'")

# Keep the program running to intercept the syscalls
try:
    while True:
        pass
except KeyboardInterrupt:
    print("Detaching program")
    exit()

