#!/bin/bash

echo "Starting VPP lite..."

/usr/bin/vpp "unix { interactive cli-listen 0.0.0.0:5002 }"
