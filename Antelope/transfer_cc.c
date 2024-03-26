#include <stdio.h>
#include <string.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>


void updateCongHash(int key, int beishu, int yushu, int result, int ipPredic) {
    char cong[5][9] = {"bbr", "cubic", "westwood"}; // TODO Change this later to include others as well
    char *pval = cong[0];
    char *ipval = cong[2];
    long ipk = beishu * 1000 + yushu;
    unsigned int cong_map_fd, ip_cong_map_fd;
    
    ip_cong_map_fd = bpf_obj_get("/sys/fs/bpf/ip_cong_map");
    cong_map_fd = bpf_obj_get("/sys/fs/bpf/cong_map");

    // Update map elements
    bpf_map_update_elem(cong_map_fd, &key, pval, BPF_ANY);

    bpf_map_update_elem(ip_cong_map_fd, &ipk, ipval,BPF_ANY);

    printf("Updated 'cong_map' and 'ip_cong_map' successfully\n");
}
