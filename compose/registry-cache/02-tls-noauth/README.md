# Registry cache experimentation

This experimentation will setup the following:

* An unsecured (self-signed certs) **HTTPS** registry **without authentication** available at *registry.dev:5000*
* An unsecured (self-signed certs) **HTTPS** registry mirror **without authentication** of *registry.dev:5000* available at *registry-mirror.dev:5000*
* A Swarm cluster with 1 manager and two workers

The registry is running in a regular bridge network with internet access.

The Swarm workers are running inside an internal network **without internet access**.

The Swarm manager is running in both networks and is hosting the the registry mirror.

# Usage

Create the required registry TLS configuration:

```
./setup-registry.sh
```

Deploy the stack:

```
docker compose up -d
```

Wait for the cluster to be ready (swarm-conductor will exit with a status 0):

```
docker compose logs -f
```

Setup the registry mirror:

```
docker compose exec -it swarm-manager1 /tmp/setup-registry-mirror.sh
```

Deploy an Edge agent on the Swarm manager:

```
# Make sure to correctly set the EDGE KEY associated to your Portainer instance first
# export EDGE_KEY=MY_EDGE_KEY

docker compose exec -it swarm-manager1 docker network create \
  --driver overlay \
  portainer_agent_network;

docker compose exec -it swarm-manager1 docker service create \
  --name portainer_edge_agent \
  --network portainer_agent_network \
  -e EDGE=1 \
  -e EDGE_ID=$(uuidgen) \
  -e EDGE_KEY=${EDGE_KEY} \
  -e EDGE_INSECURE_POLL=1 \
  -e AGENT_CLUSTER_ADDR=tasks.portainer_edge_agent \
  -e LOG_LEVEL=DEBUG \
  --mode global \
  --constraint 'node.platform.os == linux' \
  --constraint 'node.role == manager' \
  --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
  --mount type=bind,src=//var/lib/docker/volumes,dst=/var/lib/docker/volumes \
  --mount type=bind,src=//,dst=/host \
  --mount type=volume,src=portainer_agent_data,dst=/data \
  portainer/agent:2.13.1
```

Deploy the following Edge stack into the Edge environment associated with the agent deployed above:

```
version: '3'
services:
  busybox:
    image: portainer/busybox:latest
    stdin_open: true
    tty: true
    deploy:
      mode: global
      placement:
        constraints: [node.role == worker]
```
