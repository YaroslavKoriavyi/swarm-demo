#!/bin/bash

export environment=dev

docker stack deploy \
    -c ./swarm/swarm-stack.yml \
    $environment  \
    && ./docker-stack-wait.sh ${environment}
    