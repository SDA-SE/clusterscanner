#!/bin/bash

set -e

source /clusterscanner/scan-common.bash

scan_result_pre
skopeo inspect --config docker://"${IMAGE_BY_HASH}" > /dev/null || exit="true"
if [ "${exit}" == "true" ]; then
    JSON_RESULT=$(echo "${JSON_RESULT}" | jq -Sc ". += {\"status\": \"failed\"}")
    JSON_RESULT=$(echo "${JSON_RESULT}" | jq -Sc ".errors += [{\"errorText\": \"skopeo inspect failed for image\", \"command\": \"skopeo inspect docker://${IMAGE_BY_HASH}\"}]")
    scan_result_post
    exit 1
fi

# get User from docker manifest
_imageUser=$(skopeo inspect --config docker://"${IMAGE_BY_HASH}" | jq '.config.User // "ROOT"' | tr -d \")

if [[ "xX${_imageUser,,}" =~ ^xX(root|0) ]]; then
    cp /clusterscanner/runAsRoot.csv "${ARTIFACTS_PATH}/runAsRoot.csv"
    JSON_RESULT=$(echo "${JSON_RESULT}" | jq -Sc  ". += {\"status\": \"completed\", \"finding\": true, \"infoText\": \"Image is potentially running as root\"}")
else
    JSON_RESULT=$(echo "${JSON_RESULT}" | jq -Sc  ". += {\"status\": \"completed\", \"finding\": false}")
fi

scan_result_post

exit  0
