FROM ubuntu:20.04 AS buildenv

RUN useradd -u 10001 scratch

FROM scratch

USER scratch
COPY --from=buildenv /etc/passwd /etc/passwd

ENTRYPOINT [ "/my-app" ]