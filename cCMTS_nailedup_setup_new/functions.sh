#!/bin/bash

function wait_for_container_running {
    name=$1
    $( check_container_running $name )
    status=$?
    
    while [ $status -ne 0 ];
    do
    	echo "check_container_status : $name not running"
    	sleep 2
    	$(check_container_running $name)
    	status=$?
    done
}

function wait_for_k8s_container_running {
    k8s_label_name=$1
    image_name="$(kubectl get po --selector=app=$k8s_label_name --output jsonpath={.items[0].spec.containers[0].image})"
    echo "image name $image_name"
    c_id=$(docker ps --filter "ancestor=$image_name" --format {{.ID}})
    echo "container id $c_id"
    $( check_container_running $c_id )
    status=$?
    
    while [ $status -ne 0 ];
    do
    	echo "check_container_status : $c_id not running"
    	sleep 2 
        image_name="$(kubectl get po --selector=app=$k8s_label_name --output jsonpath={.items[0].spec.containers[0].image})"
        c_id=$(docker ps --filter "ancestor=$image_name" --format {{.ID}})
    	$(check_container_running $c_id)
    	status=$?
    done
    echo "check_container_status : $c_id running"
}

function check_pid_exists {
	local name=$1
	pid=$( ./docker-pid $name )
	echo $?
	if [ $? -ne 0 ];
	then
		echo "$name container not found"
		exit 1
	fi
}

function host_veth_setup {
	container_if=$1
	vswitch_if=$2
	ip link add  $container_if type veth peer name $vswitch_if 
	#ip link set dev veth0_vpp_side up
}

function host_veth_cleanup {
	if=$1
	#ip link set dev $container_if down
	ip link del $if
}

# setup for non-vpp container like US scheduler
function non_vpp_container_setup {
	local name=$1
	local if=$2
	local ip=$3
	local mac=$4

	local pid=$( ./docker-pid $name )
	ip link set netns $pid dev $if
	nsenter -t $pid -n ip link set $if up
	nsenter -t $pid -n ip addr add ${ip}/24 dev $if
	nsenter -t $pid -n ip link set $if address $mac
}

function non_vpp_container_cleanup {
	local name=$1
	local if=$2
	local pid=$( ./docker-pid $name )
	nsenter -t $pid -n ip link set $if down
	#nsenter -t $pid -n ip addr del $if
	nsenter -t $pid -n ip addr flush dev $if
	#nsenter -t $pid -n ip link delete $if
}

## unsed function
function call_vpp {
	local VPP_PCI_DEV=$1
	#docker exec -it vpp bash -c "/usr/bin/vpp \"unix { cli-listen 0.0.0.0:5002 } dpdk { dev $VPP_PCI_DEV }\""
	#docker exec -it -e VPP_PCI_DEV=$VPP_PCI_DEV vpp bash -c  ./exec.sh
}

function vpp_vswitch_route_setup {
	local name=$1
	local if=$2
	local ip=$3

	local pid=$( ./docker-pid $name )

        docker exec -it $name vppctl  ip route add $ip/32 via $id
}

function vpp_vswitch_setup {
	local name=$1
	local if=$2
	local bd=$3

	local pid=$( ./docker-pid $name )
	
	#nsenter -t $vpp_pid -n vppctl create host-interface name veth0_vpp_side
	#nsenter -t $vpp_pid -n vppctl set int state host-veth0_vpp_side up
	#nsenter -t $vpp_pid -n vppctl set interface l2 bridge host-veth0_vpp_side 1

	ip link set netns $pid dev $if
	nsenter -t $pid -n ip link set $if up
	#nsenter -t $pid -n ip link set $if address $mac

	docker exec -it $name vppctl delete host-interface name $if
	docker exec -it $name vppctl create host-interface name $if
	docker exec -it $name vppctl set int state host-$if up
	docker exec -it $name vppctl set interface l2 bridge host-$if $bd
	#docker exec -it $name vppctl set interface mac addr host-$if $mac
}

function vpp_vnf_setup {
	local name=$1
	local if=$2
	local ip=$3
	local mac=$4

	local pid=$( ./docker-pid $name )
	
	ip link set netns $pid dev $if
	nsenter -t $pid -n ip link set $if up
	nsenter -t $pid -n ip link set $if address $mac

	docker exec -it $name vppctl delete host-interface name $if
	docker exec -it $name vppctl create host-interface name $if
	docker exec -it $name vppctl set int state host-$if up
	docker exec -it $name vppctl set interface ip address host-$if  ${ip}/24
	docker exec -it $name vppctl set interface mac addr host-$if $mac
}

# applies to both VPP VNF  and vswitch
# # the cleanup allies only to provided interface
function vpp_cleanup {
	local name=$1
	local if=$2

	local pid=$( ./docker-pid $name )
	#nsenter -t $vpp_pid -n vppctl set int state host-veth0_vpp_side down
	#nsenter -t $vpp_pid -n vppctl set interface l2 bridge host-veth0_vpp_side 1
	#nsenter -t $vpp_pid -n vppctl delete host-interface name veth0_vpp_side

	#nsenter -t $vpp_pid -n vppctl set interface l2 bridge loop0 1 bvi
	#nsenter -t $vpp_pid -n vppctl set interface state loop0 down
	#nsenter -t $vpp_pid -n vppctl delete loopback interface

	docker exec -it $name vppctl set int state host-$if down
	#docker exec -it $name vppctl set interface l2 bridge host-$if 1
	docker exec -it $name vppctl delete host-interface name $if
	nsenter -t $pid -n ip link set $if down
	nsenter -t $pid -n ip addr flush dev $if
	#nsenter -t $pid -n ip link delete $if
}

function check_container_running {
	local CONTAINER=$1

	RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER)

	if [ $? -eq 1 ]; then
  		echo "UNKNOWN - $CONTAINER does not exist."
  		return 3
	fi

	if [ "$RUNNING" == "false" ]; then
  		echo "CRITICAL - $CONTAINER is not running."
  		return 2
	fi
	return 0
}
