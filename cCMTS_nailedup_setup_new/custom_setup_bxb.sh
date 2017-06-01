#!/bin/bash

# any custom setup networking or otherwise

source functions.sh
source nailedup.conf


set -x
USAGE="custom_setup_bxb"

#
# bxb per VM cfg start
#

BXB_EXT_PRE=8.$BXB_CHSS_ID
BXB_NIC_IP=$BXB_EXT_PRE.$BXB_VM_ID.1
BXB_EXT_GW=$BXB_EXT_PRE.0.1
BXB_CNR=1.2.24.102

# setup vswitch vnic interface IP/subnet and gw.
docker exec -it $VPP_VSWITCH_NAME  vppctl set interface ip address $VPP_NIC_IF $BXB_NIC_IP/16
docker exec -it $VPP_VSWITCH_NAME  vppctl ip route add $BXB_CNR/24 via $BXB_EXT_GW

# add routes in dhcp container
BXB_DHCP_GW=$BXB_DPPI_PRE.$BXB_CNT_ID_VSW
docker exec -it $DHCP_RELAY_CONT_NAME  route add -net $BXB_EXT_PRE.0.0 netmask 255.255.0.0 gw $BXB_DHCP_GW
docker exec -it $DHCP_RELAY_CONT_NAME  route add -host $BXB_CNR gw $BXB_DHCP_GW


# add routes in tftp container                                            
BXB_TFTP_GW=$BXB_DPPI_PRE.$BXB_CNT_ID_VSW
docker exec -it $TFTP_CONT_NAME  route add -net $BXB_EXT_PRE.0.0 netmask \
255.255.0.0 gw $BXB_TFTP_GW
docker exec -it $TFTP_CONT_NAME  route add -host $BXB_CNR gw $BXB_TFTP_GW




#
# bxb per VM cfg end
#
