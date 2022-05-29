# Registry cache experimentation

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

Deploy an Edge agent on the Swarm manager:
