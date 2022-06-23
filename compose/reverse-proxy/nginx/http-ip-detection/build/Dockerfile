FROM nginx:latest

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    libnginx-mod-http-geoip \
 && rm -rf /var/lib/apt/lists/*