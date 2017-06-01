#!/bin/bash

RANGING_NAME_IMAGE="$(kubectl get po --selector=app=cmts-rt-ranging --output jsonpath={.items[0].spec.containers[0].image})"
RANGING_NAME=$(docker ps --filter "ancestor=$RANGING_NAME_IMAGE" --format {{.ID}})

docker exec -it $RANGING_NAME /bin/sh

