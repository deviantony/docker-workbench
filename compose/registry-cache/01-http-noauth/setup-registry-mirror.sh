#!/usr/bin/env bash

source /opt/bash-utils/logger.sh

# First we deploy the registry that will be used to cache images

# NOTE: we need to use the network host mode here because of the docker in docker setup
# Otherwise the registry container won't be able to resolve the registry.dev hostname

INFO "Deploying registry mirror"

# HTTP registry mirror without authentication
# Mirrors a HTTP registry without authentication

docker service create --name registry-mirror \
--env REGISTRY_PROXY_REMOTEURL=http://registry.dev:5000 \
--constraint node.role==manager \
--network host \
registry:2

# We then pull a busybox image from Dockerhub and re-tag it and host it in our registry

INFO "Pulling sample image from DockerHub: busybox:latest"

docker pull busybox:latest

INFO "Re-tagging sample image to registry.dev:5000/portainer/busybox:latest"

docker tag busybox:latest registry.dev:5000/portainer/busybox:latest

INFO "Pushing sample image to registry.dev:5000/portainer/busybox:latest"

docker push registry.dev:5000/portainer/busybox:latest

exit 0