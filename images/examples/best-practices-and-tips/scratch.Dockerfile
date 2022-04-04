## Installing the root certificates in a scratch image
FROM alpine:3.6 as base
RUN apk add -U --no-cache ca-certificates

FROM scratch
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/