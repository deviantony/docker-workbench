#!/usr/bin/env bash

source /opt/bash-utils/logger.sh

# First we deploy the registry that will be used to cache images

# NOTE: we need to use the network host mode here because of the docker in docker setup
# Otherwise the registry container won't be able to resolve the registry.dev hostname

INFO "Deploying registry mirror"

# HTTPS registry mirror with authentication
# Mirrors a HTTPS registry with authentication
# We re-use the same TLS certificates as the main registry

# WARNING: this setup is not working - I believe that the mirror is not able to pass the proxy credentials correctly to the main registry
# as we can see 401 invalid authorization credentials errors in the main registry logs

docker secret create htpasswd /auth/htpasswd

docker secret create tls-cert /certs/registry.crt

docker secret create tls-key /certs/registry.key

docker service create --name registry-mirror \
--env REGISTRY_PROXY_REMOTEURL=https://registry.dev:5000 \
--env REGISTRY_PROXY_USERNAME=testuser \
--env REGISTRY_PROXY_PASSWORD=testpassword \
--secret source=htpasswd,target=/auth/htpasswd \
--env REGISTRY_AUTH=htpasswd \
--env REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
--env REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
--secret source=tls-cert,target=/certs/registry.crt \
--secret source=tls-cert,target=/usr/local/share/ca-certificates/registry.crt \
--secret source=tls-key,target=/certs/registry.key \
--env REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
--env REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
--constraint node.role==manager \
--network host \
registry:2 \
/bin/sh -c 'cat /usr/local/share/ca-certificates/registry.crt >> /etc/ssl/certs/ca-certificates.crt && ./entrypoint.sh /etc/docker/registry/config.yml'

# Alternatively, we could use the following setup:
# HTTP registry mirror without authentication
# Mirrors a HTTPS registry with authentication
# But the same problem arises, the mirror can't properly forward the registry credentials to the main registry


# docker secret create tls-cert /certs/registry.crt

# docker service create --name registry-mirror \
# --env REGISTRY_PROXY_REMOTEURL=https://registry.dev:5000 \
# --env REGISTRY_PROXY_USERNAME=testuser \
# --env REGISTRY_PROXY_PASSWORD=testpassword \
# --constraint node.role==manager \
# --secret source=tls-cert,target=/usr/local/share/ca-certificates/registry.crt \
# --network host \
# registry:2 \
# /bin/sh -c 'cat /usr/local/share/ca-certificates/registry.crt >> /etc/ssl/certs/ca-certificates.crt && ./entrypoint.sh /etc/docker/registry/config.yml'

# We then pull a busybox image from Dockerhub and re-tag it and host it in our registry

INFO "Pulling sample image from DockerHub: busybox:latest"

docker pull busybox:latest

INFO "Re-tagging sample image to registry.dev:5000/portainer/busybox:latest"

docker tag busybox:latest registry.dev:5000/portainer/busybox:latest

INFO "Pushing sample image to registry.dev:5000/portainer/busybox:latest"

docker login registry.dev:5000 -u testuser -p testpassword

docker push registry.dev:5000/portainer/busybox:latest

exit 0