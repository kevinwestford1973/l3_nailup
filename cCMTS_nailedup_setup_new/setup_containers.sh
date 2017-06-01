#!/bin/bash

set -x
USAGE="setup_containers.sh"

echo "number of args given $#"

cleanup=0
if [ ! -z "$1" ];
then
    cleanup=$1
    echo "cleanup is $1"
fi
echo "cleanup is $cleanup"
#if [ $# -eq 0 ];
#then
#  echo $USAGE 
#  exit 1 
#fi

source functions.sh

##
## These app names are label selectors used by k8s
## also make sure to modify nailedup.conf file with same variables
##
VPP_VSWITCH_APP_NAME=vswitch-vpp
RANGING_APP_NAME=cmts-rt-ranging
DP_CONT_APP_NAME=cmts-dp-macl3vpp
US_SCHED_APP_NAME=cmts-rt-usscheduler
DHCP_RELAY_APP_NAME=cmts-dp-dhcprelay
echo "wait_for_k8s_container_running $VPP_VSWITCH_APP_NAME"
wait_for_k8s_container_running $VPP_VSWITCH_APP_NAME
echo "wait_for_k8s_container_running $RANGING_APP_NAME"
wait_for_k8s_container_running $RANGING_APP_NAME
echo "wait_for_k8s_container_running $DP_CONT_APP_NAME"
wait_for_k8s_container_running $DP_CONT_APP_NAME
echo "wait_for_k8s_container_running $US_SCHED_APP_NAME"
wait_for_k8s_container_running $US_SCHED_APP_NAME
echo "wait_for_k8s_container_running $DHCP_RELAY_APP_NAME"
wait_for_k8s_container_running $DHCP_RELAY_APP_NAME
echo "check_container_status : $VPP_VSWITCH_APP_NAME is RUNNING!!!!!!!!!!!!!!!!!!!!!!"
echo "check_container_status : $RANGING_APP_NAME is RUNNING!!!!!!!!!!!!!!!!!!!!!!"
echo "check_container_status : $DP_CONT_APP_NAME is RUNNING!!!!!!!!!!!!!!!!!!!!!!"
echo "check_container_status : $US_SCHED_APP_NAME is RUNNING!!!!!!!!!!!!!!!!!!!!!!"
echo "check_container_status : $DHCP_RELAY_APP_NAME is RUNNING!!!!!!!!!!!!!!!!!!!!!!"


source nailedup.conf

rphy_if=$RPHY_IF

#pci=$(./find_pci_bus.sh $rphy_if)
pci=$VPP_PCI_DEV

printf "PCI bus number for  $rphy_if is  $pci\n"


./vswitch_basic_setup.sh

for (( i=0; i<C_IF_NUM; i++ ))
do
    ./setup_one_container.sh $i $cleanup
done

# any custom setup after the default is done, pls use the script
# below and add your code in there
if [ -n $VM_LOC ]; then
./custom_setup_$VM_LOC.sh
fi

printf "\nDONE\n"
