#!/bin/bash

#argument $1 is  etehrnet interface name e.g. eth2,  ens224 etc

#pci_dev=`lshw -c network -businfo | grep ^pci@ | grep $1 | awk '/pci@/{print $1}' | cut -d '@' -f2`
pci_dev=$1
bus_num=`echo $pci_dev | cut -d ':' -f2`
dev_num=`echo $pci_dev | cut -d ':' -f3 | cut -d '.' -f1`
function_num=`echo $pci_dev | cut -d ':' -f3 | cut -d '.' -f2`

tmp_dev_num=`echo $((dev_num+0))`

vpp_if_num="GigabitEthernet${bus_num}/${tmp_dev_num}/${function_num}"
echo $vpp_if_num


