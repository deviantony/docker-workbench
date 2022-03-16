FROM ubuntu:20.04

## Installing packages
# Re-use the following snippet to properly install packages and clean up the system (for debian based images)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    wget \
    git \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

## Installing Docker in an image
# Use the following snippet to install the Docker CLI binary in the image
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/

## Waiting for other services to be ready (Compose use case)
# Use the following tool if you need to wait for other services to be ready
# https://github.com/ufoscout/docker-compose-wait

# Example usage can be found in images/portainer/sind-conductor/Dockerfile
# and https://github.com/deviantony/templates/blob/bca33c890267b99463c3ce93efdd180e43919e4f/compose/portainer-swarm-cluster-1m-2w/docker-compose.yml#L19-L23

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait /wait
RUN chmod +x /wait

## Compiling from sources
# Use the following pattern to install tools from source in the image
# Example usage: https://github.com/portainer/client-sdk-fidoiot/blob/fa0836749cd6e9eed2ebf788a89f060a1d0862da/Dockerfile#L34-L73
WORKDIR /src/
RUN git clone --depth 1 -b v1.0.0 https://github.com/intel/safestringlib
WORKDIR /src/safestringlib/
RUN mkdir obj && make
ENV SAFESTRING_ROOT=/src/safestringlib