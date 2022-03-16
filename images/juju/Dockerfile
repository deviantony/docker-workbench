FROM ubuntu:20.04

ARG juju_major=2.9
ARG juju_minor=22

RUN apt-get update && apt-get install -y \
    curl \
    xz-utils \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -pv /tmp/download \ 
&& curl -L https://launchpad.net/juju/${juju_major}/${juju_major}.${juju_minor}/+download/juju-${juju_major}.${juju_minor}-linux-amd64.tar.xz -o /tmp/download/juju.tar.xz \
&& cd /tmp/download \
&& tar xf juju.tar.xz \
&& install -o root -g root -m 0755 juju /usr/local/bin/juju
