#!/bin/sh

if [ -z ${EDGE_KEY} ]; then
  echo "EDGE_KEY environment variable not found"
  exit 1
fi

nohup dockerd > docker.log &
echo "waiting for Docker to start"
( tail -f docker.log & ) | grep -q "API listen on /var/run/docker.sock"
pkill -s 0 tail

echo "Docker is ready - loading agent image"

docker load -i /agent.tar

echo "Agent image loaded - running agent"

PORTAINER_EDGE_ID=$(uuidgen) 

docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  -v /:/host \
  -v portainer_agent_data:/data \
  --restart always \
  -e EDGE=1 \
  -e EDGE_ID=$PORTAINER_EDGE_ID \
  -e EDGE_KEY=${EDGE_KEY} \
  -e EDGE_INSECURE_POLL=1 \
  --name portainer_edge_agent \
  portainerci/agent:develop

/bin/sh