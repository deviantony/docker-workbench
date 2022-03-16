#!/bin/sh

nohup dockerd > docker.log &
echo "waiting for Docker to start"
sleep 10

docker run -d -p ${AGENT_PORT}:9001 \
    --name portainer_agent \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    portainer/agent:2.12.1

/bin/sh