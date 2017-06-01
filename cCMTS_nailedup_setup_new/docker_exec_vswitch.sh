#!/bin/bash

VPP_VSWITCH_NAME_IMAGE="$(kubectl get po --selector=app=vswitch-vpp --output jsonpath={.items[0].spec.containers[0].image})"
VPP_VSWITCH_NAME=$(docker ps --filter "ancestor=$VPP_VSWITCH_NAME_IMAGE" --format {{.ID}})

docker exec -it $VPP_VSWITCH_NAME /bin/bash

