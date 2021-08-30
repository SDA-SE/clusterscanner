#!/bin/bash

export IMAGE=quay.io/sdase/clusterscanner-imagecollector:2.0.339 # last Version
export IMAGE=quay.io/sdase/clusterscanner-imagecollector:1.9.9
export IMAGE=quay.io/sdase/clusterscanner-imagecollector:2.0.338
export IMAGE_SCAN_POSITIVE_FILTER="quay.io/sdase/"
source env.bash
cp ../../base/scan-common.bash .

export ARTIFACTS_PATH="/tmp/cluster-image-scanner/scan-new-version"

./module.bash

rm scan-common.bash
