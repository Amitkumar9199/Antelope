/* Copyright (c) 2017 Facebook
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of version 2 of the GNU General Public
 * License as published by the Free Software Foundation.
 *
 * BPF program to set base_rtt to 80us when host is running TCP-NV and
 * both hosts are in the same datacenter (as determined by IPv6 prefix).
 *
 * Use load_sock_ops to load this BPF program.
 */
#include <linux/bpf.h>
#include <linux/bpf_common.h>
#include <sys/socket.h>
#include <linux/types.h>
#include <netinet/tcp.h>
#include <linux/swab.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

#define DEBUG 1
//struct bpf_map_def SEC("maps") cong_map = {
//	.type = BPF_MAP_TYPE_HASH,
//	.key_size = sizeof(__u32),
//	.value_size = 10,
//	.max_entries = 1024,
//};
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(key_size, sizeof(__u32));
    __uint(value_size, 10);
    __uint(max_entries, 1024);
    __uint(pinning, LIBBPF_PIN_BY_NAME);
} cong_map SEC(".maps");

//struct bpf_map_def SEC("maps") ip_cong_map = {
//	.type = BPF_MAP_TYPE_HASH,
//	.key_size = sizeof(__u32),
//	.value_size = 10,
//	.max_entries = 1024,
//};
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(key_size, sizeof(__u32));
    __uint(value_size, 10);
    __uint(max_entries, 1024);
    __uint(pinning, LIBBPF_PIN_BY_NAME);  
} ip_cong_map SEC(".maps");


static inline void init_map()
{
	long key0 = 0;
    char a[] = "illinois";
	long ikey = 0;
	char b[] = "dctcp";

    bpf_map_update_elem(&cong_map, &key0, a, BPF_ANY);	
	bpf_map_update_elem(&ip_cong_map, &ikey, b, BPF_ANY);
}

SEC("sockops")
int bpf_basertt(struct bpf_sock_ops *skops)
{
    char cong[20], ip_cong[20];
	int op = (int)skops->op;
	long dport = (long)bpf_ntohl(skops->remote_port);
	long lport = (long)skops->local_port;
	long nlip = (long)bpf_ntohl(skops->local_ip4);
	long ndip = (long)bpf_ntohl(skops->remote_ip4);
	long cc_id = dport, ip_cc_id = ndip;
    int key = 0, ikey = 3354, res;
    char *ip_con_str, *con_str;
    char a[10] = "illinois";
    char b[10] = "dctcp";

    init_map();
    bpf_map_update_elem(&cong_map, &key, a, BPF_ANY);
    bpf_map_update_elem(&ip_cong_map, &ikey, b, BPF_ANY);
    bpf_printk("dport :%ld lport:%ld\n", dport, lport);
	bpf_printk("nlip :%ld ndip:%ld\n", nlip, ndip);
	
    switch (op)
	{
	case BPF_SOCK_OPS_TCP_ACK_CB:
		bpf_printk("enter BPF_SOCK_OPS_TCP_ACK_CB\n");

		con_str = bpf_map_lookup_elem(&cong_map, &cc_id);
		bpf_printk("constr: %s\n", con_str);
		bpf_getsockopt(skops, SOL_TCP, TCP_CONGESTION,
					   cong, sizeof(cong));
		bpf_printk("before cc:%s\n", cong);

		if (con_str == NULL)
		{
			return 1;
		}

		bpf_setsockopt(skops, SOL_TCP, TCP_CONGESTION, con_str, 10);
		bpf_getsockopt(skops, SOL_TCP, TCP_CONGESTION, cong, sizeof(cong));
		//int r = bpf_map_delete_elem(&cong_map, &cc_id);
		//if (r == 0)
			//bpf_printk("Element deleted from the map\n");
		//else
		//	bpf_printk("Failed to delete element from the map: %d\n", r);
		//break;

		bpf_printk("after cc:%s\n", cong);

		break;

	case BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB:
	case BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB:
		bpf_printk("enter BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB\n");
		
		bpf_printk("ip_cc_id %ld\n", ip_cc_id);

		ip_con_str = bpf_map_lookup_elem(&ip_cong_map, &ip_cc_id);
		bpf_printk("constr: %s\n", ip_con_str);
		
		bpf_getsockopt(skops, SOL_TCP, TCP_CONGESTION,
					   ip_cong, sizeof(ip_cong));
		bpf_printk("before cc:%s\n", ip_cong);

		if (ip_con_str == NULL)
		{
			return 1;
		}

		bpf_setsockopt(skops, SOL_TCP, TCP_CONGESTION, ip_con_str, 10);
		bpf_getsockopt(skops, SOL_TCP, TCP_CONGESTION, ip_cong, sizeof(ip_cong));

		bpf_printk("after cc:%s\n", ip_cong);
		break;

	case BPF_SOCK_OPS_TCL_CLOSE_CB:
		bpf_printk("enter BPF_SOCK_OPS_TCL_CLOSE_CB\n");
		res = bpf_map_delete_elem(&cong_map, &dport);
		if (res == 0)
			bpf_printk("Element deleted from the map\n");
		else
			bpf_printk("Failed to delete element from the map: %d\n", res);
		break;
	default:
		bpf_printk("enter default\n");
		break;
	}

    skops->reply = -1;

	return 1;
}
char _license[] SEC("license") = "GPL";
