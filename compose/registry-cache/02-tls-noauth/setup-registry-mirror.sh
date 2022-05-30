#!/usr/bin/env bash

source /opt/bash-utils/logger.sh

# First we deploy the registry that will be used to cache images

# NOTE: we need to use the network host mode here because of the docker in docker setup
# Otherwise the registry container won't be able to resolve the registry.dev hostname

INFO "Deploying registry mirror"

# HTTPS registry mirror without authentication
# Mirrors a HTTPS registry without authentication
# We re-use the same TLS certificates as the main registry

docker secret create tls-cert /certs/registry.crt

docker secret create tls-key /certs/registry.key

docker service create --name registry-mirror \
--env REGISTRY_PROXY_REMOTEURL=https://registry.dev:5000 \
--secret source=tls-cert,target=/certs/registry.crt \
--secret source=tls-cert,target=/usr/local/share/ca-certificates/registry.crt \
--secret source=tls-key,target=/certs/registry.key \
--env REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
--env REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
--constraint node.role==manager \
--network host \
registry:2 \
/bin/sh -c 'cat /usr/local/share/ca-certificates/registry.crt >> /etc/ssl/certs/ca-certificates.crt && ./entrypoint.sh /etc/docker/registry/config.yml'

# We then pull a busybox image from Dockerhub and re-tag it and host it in our registry

INFO "Pulling sample image from DockerHub: busybox:latest"

docker pull busybox:latest

INFO "Re-tagging sample image to registry.dev:5000/portainer/busybox:latest"

docker tag busybox:latest registry.dev:5000/portainer/busybox:latest

INFO "Pushing sample image to registry.dev:5000/portainer/busybox:latest"

docker push registry.dev:5000/portainer/busybox:latest

exit 0