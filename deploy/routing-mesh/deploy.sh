#!/bin/bash

export environment=dev

docker stack deploy \
    -c ./routing-mesh/service-stack.yml \
    ${environment}_routing_mesh \
    && ./docker-stack-wait.sh ${environment}_routing_mesh