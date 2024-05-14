#!/bin/bash

# CHECK IF ALL ARGUMENTS HAVE BEEN PASSED
if [ -z $1 ]; then

    echo "You need to pass three arguments."
    echo "frst argument == container name"

    exit 1

fi

container_name=$1

# HEALTHCHECK FUNCTION
check_container_health() {

    # Get the health status of the container
    health_status=$(docker inspect --format='{{.State.Health.Status}}' "$1")

    # Check the health status and return 0 if healthy, 1 if unhealthy
    if [[ "$health_status" = "healthy" ]]; then
        return 0

    elif [[ "$health_status" = "starting" ]]; then
        
        echo "Container in starting state"
        sleep 15

        check_container_health $1

    else
        return 1
    fi
}

# Debugging output
#echo "Checking container: $container_name"

state_restarting=$(docker inspect --format="{{.State.Restarting}}" "$container_name")
state_running=$(docker inspect --format="{{.State.Running}}" "$container_name")

# Debugging output
#echo "Restarting: $state_restarting"
#echo "Running: $state_running"

if [ "$state_restarting" = "false" ] && [ "$state_running" = "true" ]; then
  #echo "Container is in the expected state. Exiting with status 0."
  exit 0
else
  #echo "Container is not in the expected state. Exiting with status 1."
  exit 1
fi

