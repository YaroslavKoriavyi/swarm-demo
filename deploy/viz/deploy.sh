#!/bin/bash

export environment=dev

docker stack deploy \
    -c ./viz/service-stack.yml \
    ${environment}_viz \
    && ./docker-stack-wait.sh ${environment}_viz
    