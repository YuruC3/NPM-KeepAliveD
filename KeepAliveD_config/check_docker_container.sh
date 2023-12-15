#!/bin/bash

container_name=$1

# Debugging output
echo "Checking container: $container_name"

state_restarting=$(sudo docker inspect --format="{{.State.Restarting}}" "$container_name")
state_running=$(sudo docker inspect --format="{{.State.Running}}" "$container_name" 2> /dev/null)

# Debugging output
echo "Restarting: $state_restarting"
echo "Running: $state_running"

if [ "$state_restarting" = "false" ] && [ "$state_running" = "true" ]; then
  echo "Container is in the expected state. Exiting with status 0."
  exit 0
else
  echo "Container is not in the expected state. Exiting with status 1."
  exit 1
fi

