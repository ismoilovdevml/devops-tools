#!/bin/bash

stats=$(docker stats --no-stream)

total_ram=0

echo "$stats" | awk 'NR>1 {
    container_name=$2
    ram_usage=$4
    percentage=$3
    printf("%s: %s (%s)\n", container_name, ram_usage, percentage)
    if (ram_usage ~ /GiB/) {
        sub(/GiB/, "", ram_usage)
        ram_usage *= 1024
    } else {
        sub(/MiB/, "", ram_usage)
    }
    total_ram += ram_usage
} END {
    if (total_ram >= 1024) {
        printf("\nTotal RAM usage of all containers: %.2f GB\n", total_ram / 1024)
    } else {
        printf("\nTotal RAM usage of all containers: %.2f MB\n", total_ram)
    }
}'