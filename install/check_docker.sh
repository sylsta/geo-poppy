#!/bin/bash

# Author: Erik Kristensen
# Email: erik@erikkristensen.com
# License: MIT
# Nagios Usage: check_nrpe!check_docker_container!_container_id_

# Modified by Julien ANCELIN for docker-compose
# Usage: ./check_docker.sh 
#
# List all container in a docker-compose 
# and If one or more is exit, it do a docker-compose down and up
# 

#BEFORE:
# 
# sudo nano /etc/init.d/check_docker
# sudo chmod +x /etc/init.d/check_docker
# sudo update-rc.d check_docker defaults 80 

#set -x
sleep 40
LIST=$(docker ps -aq)
for CONTAINER in $LIST
do

  RUNNING=$(docker inspect --format="{{.State.Running}}" $CONTAINER )

  if [ "$RUNNING" = "false" ]; then
    echo "CRITICAL - $CONTAINER is not running."
    docker-compose down --remove-orphans &&
    docker-compose up -d
    exit
  fi

  RESTARTING=$(docker inspect --format="{{.State.Restarting}}" $CONTAINER)

  if [ "$RESTARTING" = "true" ]; then
    echo "WARNING - $CONTAINER state is restarting."
    #exit 1
  fi

  STARTED=$(docker inspect --format="{{.State.StartedAt}}" $CONTAINER)
  NETWORK=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $CONTAINER)

  echo "OK - $CONTAINER is running. IP: $NETWORK, StartedAt: $STARTED"
  
done
exit
