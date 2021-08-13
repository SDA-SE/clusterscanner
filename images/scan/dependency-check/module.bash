#!/bin/bash
set -e

source /clusterscanner/unpack.bash
source /clusterscanner/scan-common.bash

scan_result_pre

suppressions=""
if [ -e /tmp/suppressions.xml ]; then
  echo "Found /tmp/suppressions.xml"
  suppressions='--suppression "/tmp/suppressions.xml"'
else
  echo "/tmp/suppressions.xml not existing"
fi

/usr/share/dependency-check/bin/dependency-check.sh \
    --project "test" \
    --disableRetireJS \
    --disableNodeJS \
    --disableNodeAudit \
    --disableBundleAudit \
    --scan "${IMAGE_UNPACKED_DIRECTORY}/**" \
    --out "${ARTIFACTS_PATH}" \
    --format "ALL" \
    --dbDriverName "${DEPSCAN_DB_DRIVER}" \
    --dbUser "${DEPSCAN_DB_USERNAME}" \
    --dbPassword "${DEPSCAN_DB_PASSWORD}" \
    --noupdate \
    --disableCentralCache \
    --connectionString "${DEPSCAN_DB_CONNECTSRING}" \
    $suppressions \
    >> "${ARTIFACTS_PATH}/depScan.log" || true

cat "${ARTIFACTS_PATH}/depScan.log"

if ! [ -f "${ARTIFACTS_PATH}/dependency-check-report.xml" ]; then
    JSON_RESULT=$(echo "${JSON_RESULT}" | jq -Sc ".errors += [{\"errorText\": \"Dependency check report has not been generated\", \"artifactsPath\":\"${ARTIFACTS_PATH}\"}]")
    JSON_RESULT=$(echo "${JSON_RESULT}" | jq -Sc ". += {\"status\": \"failed\"}")
    scan_result_post
    exit 1
else
    JSON_RESULT=$(echo "${JSON_RESULT}" | jq -Sc ". += {\"status\": \"completed\"}")
fi

scan_result_post
