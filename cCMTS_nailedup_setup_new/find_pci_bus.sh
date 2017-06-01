#!/bin/bash


lshw -c network -businfo | grep ^pci@ | grep $1 | awk '/pci@/{print $1}' | cut -d '@' -f2
