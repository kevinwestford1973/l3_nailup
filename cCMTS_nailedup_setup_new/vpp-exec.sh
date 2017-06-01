#!/bin/bash

echo "Starting VPP..."

if [ -z "$VPP_PCI_DEV" ]; then
  echo "PCI: no-pci"
  /usr/bin/vpp "unix { interactive cli-listen 0.0.0.0:5002 } dpdk { no-pci }"
else
  echo "PCI: $VPP_PCI_DEV"
  /usr/bin/vpp "unix { cli-listen 0.0.0.0:5002 } dpdk { dev $VPP_PCI_DEV }"
  #/usr/bin/vpp "unix { nodaemon } dpdk { dev $VPP_PCI_DEV }"
fi
