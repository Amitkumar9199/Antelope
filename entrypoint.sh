#!/bin/bash

# Mount tracefs filesystem
mount -t tracefs none /sys/kernel/tracing

/bin/bash


# docker exec h1 python3 /home/server.py --ip 192.168.10.2 --port 8080 > output.txt 2>&1
# docker exec <container_name_or_id> python3 /path/to/your/script.py > output.txt 2>&1
