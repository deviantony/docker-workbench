#!/bin/bash

MANAGERS=(${SWARM_MANAGERS//,/ })
WORKERS=(${SWARM_WORKERS//,/ })
 
MANAGER_REF=""
MANAGER_TOKEN=""
WORKER_TOKEN=""
AGENT_PORT="${AGENT_PORT}"
AGENT_VERSION="${AGENT_VERSION}"
NIC="${NIC}"

len=${#MANAGERS[@]}
for (( i=0; i<$len; i++ )); do

    # In order to get the ID of a container in the stack, we need to retrieve its IP address first.
    # Containers names are in the format "swarm-manager-<idx>" or "swarm-worker-<idx>" but are not necessarily unique on the host.
    # However they are unique across the stack network, therefore we can use the IP address as a unique identifier to retrieve the container ID.
    CNTR_IP=$(getent hosts ${MANAGERS[$i]} | awk '{ print $1 }')
    CNTR=$(echo $(docker ps -a -q) | xargs docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{.Id}}' | grep ${CNTR_IP} | cut -d ' ' -f2)

    if [[ ${i} -eq 0 ]]; then
        MANAGER_REF=${MANAGERS[$i]}
        echo "Initializing Swarm on ${MANAGER_REF}"

        # Init Swarm
        if [[ -n ${NIC} ]];
        then
            # If the NIC parameter is set, we advertise on the specified NIC
            docker exec ${CNTR} sh -c "docker swarm init --advertise-addr ${NIC}"
        else
            docker exec ${CNTR} sh -c "docker swarm init"
        fi;
        

        # Deploy the Portainer agent
        # We only deploy the Portainer agent when the AGENT_PORT and AGENT_VERSION variables are set.
        if [[ -n "${AGENT_PORT}" ]] && [[ -n ${AGENT_VERSION} ]]; then 
            docker exec ${CNTR} sh -c "docker network create --driver overlay --attachable portainer_agent_net"

            docker exec ${CNTR} sh -c "docker service create -d \
                --publish published=${AGENT_PORT},target=9001,protocol=tcp,mode=host \
                --name portainer_agent \
                --mode global \
                --network portainer_agent_net \
                --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
                --mount type=bind,source=/var/lib/docker/volumes,target=/var/lib/docker/volumes \
                portainer/agent:${AGENT_VERSION}"
        fi

        # Retrieve the Swarm tokens
        MANAGER_TOKEN=$(docker exec ${CNTR} sh -c "docker swarm join-token -q manager")
        echo "Manager token: ${MANAGER_TOKEN}"
        WORKER_TOKEN=$(docker exec ${CNTR} sh -c "docker swarm join-token -q worker")
        echo "Worker token: ${WORKER_TOKEN}"
    else
        echo "Joining Swarm as manager - ${MANAGERS[$i]}"

        docker exec ${CNTR} sh -c "docker swarm join --token ${MANAGER_TOKEN} ${MANAGER_REF}:2377"
    fi
done

len=${#WORKERS[@]}
for (( i=0; i<$len; i++ )); do 
    CNTR_IP=$(getent hosts ${WORKERS[$i]} | awk '{ print $1 }')
    CNTR=$(echo $(docker ps -a -q) | xargs docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{.Id}}' | grep ${CNTR_IP} | cut -d ' ' -f2)

    echo "Joining Swarm as worker - ${WORKERS[$i]}"

    docker exec ${CNTR} sh -c "docker swarm join --token ${WORKER_TOKEN} ${MANAGER_REF}:2377"
done

exit 0