#!/bin/bash
set -euo pipefail

# Use an explicit format so the column positions are stable. The default
# `docker stats` table puts MEM USAGE / LIMIT across three whitespace-separated
# fields ("10.5MiB", "/", "7.667GiB"), which made positional parsing pick the
# CPU percentage instead of the memory percentage.
stats=$(docker stats --no-stream --format '{{.Name}}\t{{.MemUsage}}\t{{.MemPerc}}')

echo "$stats" | awk -F'\t' '
{
    container_name = $1
    ram_usage = $2
    sub(/ *\/.*/, "", ram_usage)   # keep only the "used" side of "used / limit"
    percentage = $3

    printf("%s: %s (%s)\n", container_name, ram_usage, percentage)

    value = ram_usage + 0
    if (ram_usage ~ /GiB/)      { value *= 1024 }
    else if (ram_usage ~ /KiB/) { value /= 1024 }
    else if (ram_usage ~ /B$/ && ram_usage !~ /iB$/) { value /= 1048576 }

    total_ram += value
}
END {
    if (total_ram >= 1024) {
        printf("\nTotal RAM usage of all containers: %.2f GiB\n", total_ram / 1024)
    } else {
        printf("\nTotal RAM usage of all containers: %.2f MiB\n", total_ram)
    }
}'
