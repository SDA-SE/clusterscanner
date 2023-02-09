#!/bin/bash

set -e
source /clusterscanner/scan-common.bash
scan_result_pre

echo "Starting Syft with parameter '$@ > /clusterscanner/data/bom.json'"
/syft "$@" --quiet > /clusterscanner/data/bom.json # --file doesn't work in this container

if [ -f /clusterscanner/data/bom.json ]; then
  echo  "/clusterscanner/data/bom.json doesn't exists"
  exit 2
fi
scan_result_post

exit  0
