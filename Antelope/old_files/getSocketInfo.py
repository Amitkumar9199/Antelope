# BCC file to probe in the strcut socket parameter information
from bcc import BPF
from socket import inet_ntop, AF_INET, AF_INET6
import ctypes as ct
import struct

# define BPF program
bpf_text = """
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <linux/tcp.h>

// separate data structs for ipv4 and ipv6
struct data_t {
    u32 pid;
    u64 ip;
    u32 saddr;
    u32 daddr;
    u16 lport;
    u16 dport;
    u64 state;
    u64 tcp_state;
    u64 srtt;
    u64 rtt;
    u64 mdev;
    u64 mdev_max;
    u64 rttvar;
    u64 min_rtt;
    u64 inflight;
    u64 lost;
    u64 recv_rtt;
    u64 tsoffset;
    u64 retrans_out;
    u64 total_lost;
    u64 sack_out;
    u64 total_retrans;
    u64 tstamp;
    u64 rcv_buf;
    u64 snd_buf;
    u64 snd_cwnd;
    u64 sk_max_pacing_rate;
    u64 sk_pacing_rate;
    u64 delivered;
};
BPF_PERF_OUTPUT(events);

int trace_ack(struct pt_regs *ctx, struct sock *sk) {
    struct data_t data = {};

    if (sk == NULL) {
        return 0;
    }
    u32 pid = bpf_get_current_pid_tgid() >> 32;
    u16 family = sk->__sk_common.skc_family;
    u16 lport = sk->__sk_common.skc_num;
    u16 dport = sk->__sk_common.skc_dport;
    char state = sk->__sk_common.skc_state;
    struct tcp_sock *tp = (struct tcp_sock *)sk;
    struct tcp_rack rack = tp->rack;
    struct minmax min = tp->rtt_min;
    struct inet_connection_sock *icsk = inet_csk(sk);
    u64 tcp_state=0;

    if (family == AF_INET) {
        data.pid = pid;
        data.lport = lport;
        data.dport = ntohs(dport);
        data.state = state;
        data.tcp_state = tcp_state;
        data.srtt = tp->srtt_us;
        data.rtt = rack.rtt_us;
        data.mdev = tp->mdev_us;
        data.mdev_max = tp->mdev_max_us;
        data.rttvar = tp->rttvar_us;
        data.min_rtt = min.s[0].v;
        data.inflight = tp->packets_out;
        data.lost = tp->lost_out;
        data.recv_rtt = tp->rcv_rtt_est.rtt_us;
        data.tsoffset = tp->tsoffset;
        data.retrans_out = tp->retrans_out;
        data.total_lost = tp->lost;
        data.sack_out = tp->sacked_out;
        data.total_retrans = tp->total_retrans;
        data.tstamp = tp->lsndtime;
        data.rcv_buf = sk->sk_rcvbuf;
        data.snd_buf = sk->sk_sndbuf;
        data.snd_cwnd = tp->snd_cwnd;
        data.sk_max_pacing_rate = sk->sk_max_pacing_rate;
        data.sk_pacing_rate = sk->sk_pacing_rate;
        data.delivered = tp->delivered;
        if (family == AF_INET) {
            data.ip = 4;
            data.saddr = sk->__sk_common.skc_rcv_saddr;
            data.daddr = sk->__sk_common.skc_daddr;
        } else {
            data.ip = 6;
            bpf_probe_read(&data.saddr, sizeof(data.saddr),
                           sk->__sk_common.skc_v6_rcv_saddr.in6_u.u6_addr32);
            bpf_probe_read(&data.daddr, sizeof(data.daddr),sk->__sk_common.skc_v6_daddr.in6_u.u6_addr32);
        }
    }

    events.perf_submit(ctx, &data, sizeof(data));

    return 0;
}
"""

# event data
class Data_ipv4(ct.Structure):
    _fields_ = [
        ("pid", ct.c_uint),
        ("ip", ct.c_ulonglong),
        ("saddr", ct.c_uint),
        ("daddr", ct.c_uint),
        ("lport", ct.c_ushort),
        ("dport", ct.c_ushort),
        ("state", ct.c_ulonglong),
        ("tcp_state", ct.c_ulonglong),
        ("srtt", ct.c_ulonglong),
        ("rtt", ct.c_ulonglong),
        ("mdev", ct.c_ulonglong),
        ("mdev_max", ct.c_ulonglong),
        ("rttvar", ct.c_ulonglong),
        ("min_rtt", ct.c_ulonglong),
        ("inflight", ct.c_ulonglong),
        ("lost", ct.c_ulonglong),
        ("recv_rtt", ct.c_ulonglong),
        ("tsoffset", ct.c_ulonglong),
        ("retrans_out", ct.c_ulonglong),
        ("total_lost", ct.c_ulonglong),
        ("sack_out", ct.c_ulonglong),
        ("total_retrans", ct.c_ulonglong),
        ("tstamp", ct.c_ulonglong),
        ("rcv_buf", ct.c_ulonglong),
        ("snd_buf", ct.c_ulonglong),
        ("snd_cwnd", ct.c_ulonglong),
        ("sk_max_pacing_rate", ct.c_ulonglong),
        ("sk_pacing_rate", ct.c_ulonglong),
        ("delivered", ct.c_ulonglong)
    ]

class Data_ipv6(ct.Structure):
    _fields_ = [
        ("pid", ct.c_uint),
        ("ip", ct.c_ulonglong),
        ("saddr", (ct.c_ulonglong * 2)),
        ("daddr", (ct.c_ulonglong * 2)),
        ("lport", ct.c_ushort),
        ("dport", ct.c_ushort),
        ("state", ct.c_ulonglong),
        ("tcp_state", ct.c_ulonglong),
        ("rtt", ct.c_ulonglong),
        ("srtt", ct.c_ulonglong),
        ("mdev", ct.c_ulonglong),
        ("mdev_max", ct.c_ulonglong),
        ("rttvar", ct.c_ulonglong),
        ("min_rtt", ct.c_ulonglong),
        ("inflight", ct.c_ulonglong),
        ("lost", ct.c_ulonglong),
        ("recv_rtt", ct.c_ulonglong),
        ("tsoffset", ct.c_ulonglong),
        ("retrans_out", ct.c_ulonglong),
        ("total_lost", ct.c_ulonglong),
        ("sack_out", ct.c_ulonglong),
        ("total_retrans", ct.c_ulonglong),
        ("tstamp", ct.c_ulonglong),
        ("rcv_buf", ct.c_ulonglong),
        ("snd_buf", ct.c_ulonglong),
        ("snd_cwnd", ct.c_ulonglong),
        ("sk_max_pacing_rate", ct.c_ulonglong),
        ("sk_pacing_rate", ct.c_ulonglong),
        ("delivered", ct.c_ulonglong)
    ]


# initialize BPF
b = BPF(text=bpf_text)
b.attach_kprobe(event="tcp_ack", fn_name="trace_ack")

# from include/net/tcp_states.h:
tcpstate = {}
tcpstate[0] = 'NONE'
tcpstate[1] = 'ESTABLISHED'
tcpstate[2] = 'SYN_SENT'
tcpstate[3] = 'SYN_RECV'
tcpstate[4] = 'FIN_WAIT1'
tcpstate[5] = 'FIN_WAIT2'
tcpstate[6] = 'TIME_WAIT'
tcpstate[7] = 'CLOSE'
tcpstate[8] = 'CLOSE_WAIT'
tcpstate[9] = 'LAST_ACK'
tcpstate[10] = 'LISTEN'
tcpstate[11] = 'CLOSING'
tcpstate[12] = 'NEW_SYN_RECV'

state = {}
state[0] = 'open'
state[1] = 'disorder'
state[2] = 'cwr'
state[3] = 'recovery'
state[4] = 'loss'

# process event
def print_event(cpu, data, size):
    # TODO: Find a way to extract data from b["(ipv4_)events"]
    # ct.cast returns a new instance of *Data_ipv4 which points to the same mem
    # block as data
    # "data" must be an object that can be interpreted as a pointer
    # here, it returns a new instance of *Data_ipv4 and .contents() is used to
    # dereference it
    event = ct.cast(data, ct.POINTER(Data_ipv4)).contents
    # event = b["events"].event(data)
    # better use string.format()
    saddr = ""
    daddr = ""
    if (event.ip == 4):
        saddr = inet_ntop(AF_INET, struct.pack("!I", event.saddr))
        daddr = inet_ntop(AF_INET, struct.pack("!I", event.daddr))
    elif (event.ip == 6):
        # TODO: I: unsigned int, but saddr is unsigned long long * 2
        saddr = inet_ntop(AF_INET6, struct.pack("!I", event.saddr)),
        daddr = inet_ntop(AF_INET6, struct.pack("!I", event.daddr))

    print(event.tstamp,
          saddr,
          event.lport, # not used in recvSetCC
          daddr,
          event.dport,
          event.srtt,
          event.mdev,
          event.min_rtt,
          event.inflight,
          event.total_lost,
          event.total_retrans,
          event.rcv_buf,
          event.snd_buf,
          event.snd_cwnd,
          tcpstate[event.state],
          state[event.tcp_state], # not used in recvSetCC
          event.sk_pacing_rate,
          event.sk_max_pacing_rate, # not used in recvSetCC
          event.delivered
        )

b["events"].open_perf_buffer(print_event)

while 1:
    b.perf_buffer_poll()
