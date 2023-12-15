#!/bin/bash

# CHECK IF ALL ARGUMENTS HAVE BEEN PASSED
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then

    echo "You need to pass three arguments."
    echo "frst argument == container name"
    echo "scnd argument == local_username"
    echo "thrd argument == remote_username" 

    exit

fi

# RSYNC FUNCTION
rsync_npmz () {
    # $1 == local_username input
    # $2 == remote_username input

    # NODE-1
    rsync -avru /home/$1/npm/ $2@<NODE_1_IP>:/home/$2/npm/

    # NODE-2
    rsync -avru /home/$1/npm/ $2@<NODE_2_IP>:/home/$2/npm/

}

# DEF VARIABLE NAMES
container_name=$1
local_username=$2
remote_username=$3

state_restarting=$(sudo docker inspect --format="{{.State.Restarting}}" "$container_name")
state_running=$(sudo docker inspect --format="{{.State.Running}}" "$container_name" 2> /dev/null)

# MAIN CODE
if [ "$state_restarting" = "false" ] && [ "$state_running" = "true" ]; then

    echo "Container is up, that's goood."

    sleep 30;

    rsync_npmz $local_username $remote_username

else
    echo "Container is down, tho it should not be."
    
    rsync_npmz $local_username $remote_username
fi

# AFTER RSYNCING
sudo docker-compose -f "/home/$local_username/npm/docker-compose.yml" up

echo "NPM has been started."
echo "Bye"
