#!/usr/bin/env bash

set -e

# logging

ESeq="\x1b["
RCol="$ESeq"'0m'
BIRed="$ESeq"'1;91m'
BIGre="$ESeq"'1;92m'
BIYel="$ESeq"'1;93m'
BIWhi="$ESeq"'1;97m'

printSection() {
  echo -e "${BIYel}>>>> ${BIWhi}${1}${RCol}"
}

info() {
  echo -e "${BIWhi}${1}${RCol}"
}

success() {
  echo -e "${BIGre}${1}${RCol}"
}

error() {
  echo -e "${BIRed}${1}${RCol}"
}

errorAndExit() {
  echo -e "${BIRed}${1}${RCol}"
  exit 1
}

# !logging

[[ "$(command -v openssl)" ]] || errorAndExit "Unable to find openssl binary. Please ensure openssl is installed before running this script."

# First, we generate TLS certificates to expose the registries over HTTPS.
# Same cert/key will be used for both registries.

info "Generating TLS certs for registry.dev and registry-mirror.dev"

rm -rf certs/*.crt,*.key

openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout certs/registry.key \
  -addext "subjectAltName = DNS:registry.dev,DNS:registry-mirror.dev" \
  -x509 -days 365 -out certs/registry.crt

exit 0