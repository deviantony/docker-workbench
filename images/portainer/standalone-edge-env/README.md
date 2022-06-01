# Standalone Edge environment

Make sure to export the agent image locally before building this image:

```
docker pull portainer/agent:2.13.1
docker save -o agent.tar portainer/agent:2.13.1
```