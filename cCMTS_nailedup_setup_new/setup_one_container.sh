#!/bin/bash

# stich network connection and assign IP addresses for a container
# specified by  its number(index)  in nailedup.conf file
# The number(index) is the index used in C_*[] array in
# nailedup.conf

#assumption is that container is already running

source functions.sh
source nailedup.conf


set -x
USAGE="setup_one_container.sh <container number from nailedup.conf file > <cleanup>"
USAGE2="cleanup: 1 means the existing link and interfaces will be deleted and new links/interfaces will be created"

echo "number of args given $#"

if [ $# -eq 0 ];
then
  echo $USAGE
  echo $USAGE2 
  exit 1 
fi

i=$1

cleanup=0
if [ ! -z "$2" ];
then
    cleanup=$2
    echo "cleanup is $2"
fi
echo "cleanup is $cleanup"

printf "Container number is $1"

rphy_if=$RPHY_IF

#pci=$(./find_pci_bus.sh $rphy_if)
pci=$VPP_PCI_DEV

printf "PCI bus number for  $rphy_if is  $pci"

wait_for_container_running ${C_NAME[$i]}
echo "check_container_status : ${C_NAME[$i]} is RUNNING!!!!!!!!!!!!!!!!!!!!!!"
check_pid_exists ${C_NAME[$i]}
      
#derive names of veth pairs
#name MUST be short ( 15 characters or less)
container_if=veth_${C_IF_NAME[$i]}
vswitch_if=veth_s_${C_IF_NAME[$i]}
bd=${C_IF_BD[$i]}


if [[ $cleanup -eq 1 ]]
then
    if [[ ${C_TYPE[$i]} == "VPP" ]]
    then
     	    vpp_cleanup ${C_NAME[$i]} $container_if
    else
      	    non_vpp_container_cleanup ${C_NAME[$i]} $container_if
    fi
    vpp_cleanup $VPP_VSWITCH_NAME  $vswitch_if
    host_veth_cleanup $vswitch_if
fi

echo "host_veth_setup $container_if $vswitch_if"
host_veth_setup $container_if $vswitch_if
echo "vpp_vswitch_setup $VPP_VSWITCH_NAME  $vswitch_if $bd"
vpp_vswitch_setup $VPP_VSWITCH_NAME  $vswitch_if $bd

if [[ ${C_TYPE[$i]} == "VPP" ]]
then
    echo "vpp_vnf_setup ${C_NAME[$i]} $container_if ${C_IP[$i]} ${C_MAC[$i]}"
    vpp_vnf_setup ${C_NAME[$i]} $container_if ${C_IP[$i]} ${C_MAC[$i]}
else
    echo "non_vpp_container_setup ${C_NAME[$i]} $container_if ${C_IP[$i]} ${C_MAC[$i]}"
    non_vpp_container_setup ${C_NAME[$i]} $container_if ${C_IP[$i]} ${C_MAC[$i]}
fi

printf "\nDONE  with this container ${C_NAME[$i]}\n"
