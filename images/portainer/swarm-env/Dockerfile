FROM docker:20-dind

COPY docker-entrypoint.sh /

ENV AGENT_PORT 9001
EXPOSE ${AGENT_PORT}/tcp

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 CMD netstat -an | grep ${AGENT_PORT} > /dev/null; if [ 0 != $? ]; then exit 1; fi;

ENTRYPOINT [ "./docker-entrypoint.sh" ]