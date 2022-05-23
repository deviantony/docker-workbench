FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    dialog \
    apt-utils \
    curl \
    build-essential \
    git \
    wget \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    libarchive-tools \
    software-properties-common \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && apt-get -y install nomad

ENTRYPOINT [ "nomad", "agent", "-dev", "-bind", "0.0.0.0", "-log-level", "INFO" ]