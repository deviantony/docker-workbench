FROM ubuntu:20.04

COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/

# https://github.com/ufoscout/docker-compose-wait
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait /wait
RUN chmod +x /wait

ADD setup-cluster.sh /

CMD /wait && /setup-cluster.sh