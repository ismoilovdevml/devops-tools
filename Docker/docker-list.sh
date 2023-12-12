#!/bin/bash

# Get container names
container_names=$(docker ps --format '{{.Names}}')

echo "Container Names and Ports:"
echo "--------------------------"

# Iterate through each container
for container_name in $container_names
do
    echo "Container: $container_name"
    
    # Get ports for the container
    container_ports=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}} -> {{$p}} {{end}}' $container_name)
    
    # Check if ports are exposed
    if [ -z "$container_ports" ]; then
        echo "No ports exposed for this container."
    else
        echo "Exposed Ports:"
        echo "$container_ports" | column -t -s ' '
    fi

    echo "--------------------------"
done
