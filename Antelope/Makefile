all:
	clang -O2 -g -Wall -target bpf  -c tcp_changecc_kern.c -o tcp_changecc_kern.o
	gcc -shared -fPIC -o transfer_cc.so transfer_cc.c -lbpf
clean:
	rm tcp_changecc_kern.o transfer_cc.so
