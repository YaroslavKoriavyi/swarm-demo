# Docker Swarm Presentation

## Presentation
[Slides TBD]()


## Building a docker swarm cluster
```
for i in 1 2 3; do
    docker-machine create -d virtualbox swarm-n$i
done
```

Checking my machines
```
docker-machine ls
```

The output is
```
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
swarm-n1   -        virtualbox   Running   tcp://192.168.99.100:2376           v1.18.9
swarm-n2   -        virtualbox   Running   tcp://192.168.99.101:2376           v1.18.9
swarm-n3   -        virtualbox   Running   tcp://192.168.99.102:2376           v1.18.9
```

Creating the cluster
```
eval "$(docker-machine env swarm-n1)"

docker swarm init --advertise-addr $(docker-machine ip swarm-n1)
```

## Adding the visualizer service
```
eval "$(docker-machine env swarm-n1)"
docker service create \
  --name=visualizer \
  --publish=8000:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer

open http://$(docker-machine ip swarm-n1):8000
```

## Adding workers to the cluster
```
eval "$(docker-machine env swarm-n1)"
JOIN_TOKEN=$(docker swarm join-token -q worker)

for i in 2 3; do
    eval "$(docker-machine env swarm-n$i)"

    docker swarm join --token $JOIN_TOKEN \
        --advertise-addr $(docker-machine ip swarm-n$i) \
        $(docker-machine ip swarm-n1):2377
done
```

```
eval "$(docker-machine env swarm-n1)"
docker node ls
```

## Creating network
```
eval "$(docker-machine env swarm-n1)"
docker network create -d overlay routing-mesh
```

## Deploy a new service
```
eval "$(docker-machine env swarm-n1)"
docker service create \
  --name=docker-routing-mesh \
  --publish=8080:8080/tcp \
  --network routing-mesh \
  --reserve-memory 20m \
  albertogviana/docker-routing-mesh:1.0.0
```

## Testing the service
```
curl http://$(docker-machine ip swarm-n1):8080
curl http://$(docker-machine ip swarm-n2):8080
curl http://$(docker-machine ip swarm-n3):8080
```

## Scaling a service
```
docker service scale docker-routing-mesh=3
```

## Calling a service
```
while true; do curl http://$(docker-machine ip swarm-n1):8080; sleep 1; echo "\n";  done
```

## Rolling updates
```
eval "$(docker-machine env swarm-n1)"
docker service update \
  --update-failure-action pause \
  --update-parallelism 1 \
  --image albertogviana/docker-routing-mesh:2.0.0 \
  docker-routing-mesh
```

## Calling a service
```
while true; do curl http://$(docker-machine ip swarm-n1):8080/health; sleep 1; echo "\n";  done
```

## Docker secret create
```
echo test | docker secret create my_secret -
```

## Docker secret ls
```
docker secret ls
```

## Deploy my secret
```
eval "$(docker-machine env swarm-n1)"
docker service update \
  --update-failure-action pause \
  --update-parallelism 1 \
  --secret-add my_secret \
  --image albertogviana/docker-routing-mesh:2.0.0 \
  docker-routing-mesh
```

## Drain a node
```
docker node update --availability=drain swarm-n3
```

## Listing nodes
```
docker node ls
```

## Bring the node back
```
docker node update --availability=active swarm-n3
```

## Add Manager
```
docker node promote swarm-n2
```

## Remove Manager
```
docker node promote swarm-n2
```

## PLACEMENT PREFERENCES
```

docker service rm docker-routing-mesh

docker service create \
  --mode=global \
  --name=docker-routing-mesh \
  --publish=8080:8080/tcp \
  --network routing-mesh \
  --reserve-memory 20m \
  albertogviana/docker-routing-mesh:2.0.0

```


## Docker system info
```
docker system info
```

## Docker and disk?
```
docker system df
```

## Docker clean up
```
docker system prune
```