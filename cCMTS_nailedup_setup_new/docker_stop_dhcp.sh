#!/bin/bash

DHCP_RELAY_APP_NAME=cmts-dp-dhcprelay
DHCP_RELAY_CONTAINER_IMAGE="$(kubectl get po --selector=app=$DHCP_RELAY_APP_NAME --output jsonpath={.items[0].spec.containers[0].image})"
DHCP_RELAY_CONT_NAME=$(docker ps --filter "ancestor=$DHCP_RELAY_CONTAINER_IMAGE" --format {{.ID}})

docker stop $DHCP_RELAY_CONT_NAME

