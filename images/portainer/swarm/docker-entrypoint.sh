#!/bin/sh

nohup dockerd > docker.log &
echo "waiting for Docker to start"
sleep 10

docker swarm init

/bin/sh