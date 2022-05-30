# Registry cache experimentation

This experimentation will setup the following:

* An unsecured (self-signed certs) **HTTPS** registry **with authentication** (credentials: testuser/testpassword) available at *registry.dev:5000*
* An unsecured (self-signed certs) **HTTPS** registry mirror **with authentication** (credentials: mirroruser/mirrorpassword) of *registry.dev:5000* available at *registry-mirror.dev:5000*
* A Swarm cluster with 1 manager and two workers

The registry is running in a regular bridge network with internet access.

The Swarm workers are running inside an internal network **without internet access**.

The Swarm manager is running in both networks and is hosting the the registry mirror.

It is important to note that the client must authenticate to the registry mirror first and then re-use the same credentials for DockerHub - as the docker client always tries to use DockerHub credentials when using a registry mirror (see: https://github.com/moby/moby/issues/30880#issuecomment-798807332)

```
# We login against the mirror first
docker login registry-mirror.dev:5000 -u mirroruser -p mirrorpassword
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

# We then replace the mirror URL with DockerHub URL in the Docker client config
sed -i 's/registry-mirror.dev:5000/https:\/\/index.docker.io\/v1\//g' ~/.docker/config.json

# We can now pull and the client will authenticate against the registry mirror properly
docker pull portainer/busybox:latest
```

**WARNING**: this setup is not working - I believe that the mirror is not able to pass the proxy credentials correctly to the main registry as we can see 401 invalid authorization credentials errors in the main registry logs.

# Usage

Create the required registry TLS/auth configuration:

```
./setup-registry.sh
```

Deploy the stack:

```
docker compose up -d
```

Wait for the cluster to be ready (swarm-conductor will exit with a status 0):

```
docker compose logs -f
```

Setup the registry mirror:

```
docker compose exec -it swarm-manager1 /tmp/setup-registry-mirror.sh
```


