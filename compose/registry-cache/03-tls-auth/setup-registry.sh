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

# Then, we create a htpasswd file to add authentication to the registry.
# It is using a simple username/password set to testuser/testpassword.

info "Generating htpasswd file for registry.dev (credentials: testuser/testpassword)"

rm -rf auth/*

docker run --rm --entrypoint htpasswd httpd:2 -Bbn testuser testpassword > auth/htpasswd

info "Generating htpasswd file for registry-mirror.dev (credentials: mirroruser/mirrorpassword)"

docker run --rm --entrypoint htpasswd httpd:2 -Bbn mirroruser mirrorpassword > auth/htpasswd-mirror

exit 0