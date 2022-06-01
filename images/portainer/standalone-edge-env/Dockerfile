FROM docker:20-dind

RUN apk add --no-cache uuidgen

COPY docker-entrypoint.sh /

COPY agent.tar /

# HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 CMD netstat -an | grep ${AGENT_PORT} > /dev/null; if [ 0 != $? ]; then exit 1; fi;

ENTRYPOINT [ "./docker-entrypoint.sh" ]