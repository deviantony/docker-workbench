#!/bin/sh

nohup dockerd > docker.log &
echo "waiting for Docker to start"
sleep 10

docker swarm init

docker network create --driver overlay --attachable portainer_agent_net

docker service create -d --publish ${AGENT_PORT}:9001 \
    --name portainer_agent \
    --mode global \
    --network portainer_agent_net \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    --mount type=bind,source=/var/lib/docker/volumes,target=/var/lib/docker/volumes \
    portainer/agent:2.12.1

/bin/sh