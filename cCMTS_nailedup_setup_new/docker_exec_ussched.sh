#!/bin/bash

US_SCHED_APP_NAME=cmts-rt-usscheduler
US_SCHED_CONTAINER_IMAGE="$(kubectl get po --selector=app=$US_SCHED_APP_NAME --output jsonpath={.items[0].spec.containers[0].image})"
US_SCHED_CONT_NAME=$(docker ps --filter "ancestor=$US_SCHED_CONTAINER_IMAGE" --format {{.ID}})

docker exec -it $US_SCHED_CONT_NAME /bin/sh

