#!/bin/bash

source functions.sh
source nailedup.conf

function vswitch_basic_setup {
	local name=$1
	local pci_dev=$2

	vpp_if_num=$(./convert_pci_dev_to_vpp_if_name.sh $pci_dev)
	docker exec -it $name vppctl set int state $vpp_if_num up
	#docker exec -it $name vppctl set interface l2 bridge $vpp_if_num 1

	docker exec -it $name vppctl create loopback interface mac 02:00:00:AA:BB:00 instance 0
	docker exec -it $name vppctl set interface l2 bridge loop0 1 bvi
	docker exec -it $name vppctl set interface state loop0 up
	docker exec -it $name vppctl set interface ip address loop0 2001::ffff/64
	docker exec -it $name vppctl set interface ip address loop0 ${VPP_VSWITCH_LOOP0_IP}/24
        docker exec -it $name vppctl set int ip table loop0 0
        docker exec -it $name vppctl ip route table 0 $VPP_VSWITCH_LOOP0_SUBNET via loop0

	docker exec -it $name vppctl create loopback interface mac 02:00:00:AA:BB:01 instance 1
	docker exec -it $name vppctl set interface l2 bridge loop1 2 bvi
	docker exec -it $name vppctl set interface state loop1 up
	docker exec -it $name vppctl set interface ip address loop1 2001::ffff/64
	docker exec -it $name vppctl set interface ip address loop1 ${VPP_VSWITCH_LOOP1_IP}/24 
        docker exec -it $name vppctl set int ip table loop1 0
        docker exec -it $name vppctl ip route table 0 $VPP_VSWITCH_LOOP1_SUBNET via loop1

	docker exec -it $name vppctl create loopback interface mac 02:00:00:AA:BB:02 instance 2
	docker exec -it $name vppctl set interface l2 bridge loop2 3 bvi
	docker exec -it $name vppctl set interface state loop2 up
	docker exec -it $name vppctl set interface ip address loop2 2001::ffff/64
	docker exec -it $name vppctl set interface ip address loop2 ${VPP_VSWITCH_LOOP2_IP}/24
        docker exec -it $name vppctl set int ip table loop2 0
        docker exec -it $name vppctl ip route table 0 $VPP_VSWITCH_LOOP2_SUBNET via loop2

	docker exec -it $name vppctl create loopback interface mac 02:00:00:AA:BB:03 instance 3
	docker exec -it $name vppctl set interface l2 bridge loop3 4 bvi
	docker exec -it $name vppctl set interface state loop3 up
	docker exec -it $name vppctl set interface ip address loop3 2001::ffff/64
	docker exec -it $name vppctl set interface ip address loop3 ${VPP_VSWITCH_LOOP3_IP}/24
        docker exec -it $name vppctl set int ip table loop3 0
        docker exec -it $name vppctl ip route table 0 $VPP_VSWITCH_LOOP3_SUBNET via loop3
}


set -x
USAGE="vswitch_setup"

echo "number of args given $#"

rphy_if=$RPHY_IF
#make sure nic is there
x=$(ifconfig | grep ens)
y=$rphy_if
if [[ $x == *$y* ]]; then
    echo "ifconfig $rphy_if down"
    ifconfig $rphy_if down
fi

#pci=$(./find_pci_bus.sh $rphy_if)
pci=$VPP_PCI_DEV
echo "PCI bus number for  $rphy_if is  $pci"

wait_for_container_running $VPP_VSWITCH_NAME
echo "check_container_status : $VPP_VSWITCH_NAME is RUNNING!!!!!!!!!!!!!!!!!!!!!!"
check_pid_exists $VPP_VSWITCH_NAME


vswitch_basic_setup $VPP_VSWITCH_NAME $pci

printf "\nDONE  WITH VSWITCH basic setup\n"
