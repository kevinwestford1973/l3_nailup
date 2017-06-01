setup various cCMTS containers with nailed-up connectivity and IP/MAC addresses. 
No GCP/L2TPv3.. 
There is VPP based vSwitch 
These scripts can be used for simple setup without K8 or "SDN controller" 

After git clone-
examine the nailedup.conf file  that serves as a  template for wiring and IP addressing/subnet.
Goal is to be able to use this file as is, but there may be changes needed for some setups for IP addresses.

./setup_containers.sh   

will connect the DP( VPP) and non-VPP containers to the VPP vswitch
also assign IP and MAC addresses to various interfaces on the containers

