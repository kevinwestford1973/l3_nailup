#!/bin/bash

DP_CONTAINER_IMAGE="$(kubectl get po --selector=app=cmts-dp-macl3vpp --output jsonpath={.items[0].spec.containers[0].image})"
DP_CONT_NAME=$(docker ps --filter "ancestor=$DP_CONTAINER_IMAGE" --format {{.ID}})

docker stop $DP_CONT_NAME

