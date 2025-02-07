#!/bin/bash

SOURCE_FILE=$1 # md from doc
TARGET=$2 # What to extract Response or Relevance
TARGET_FILE=$3 # Target JSON file
TEMP_FILE="/tmp/tmp-file-to-create-markdown"
heading="##"

if [ "${TARGET}" != "Response" ] && [ "${TARGET}" != "Relevance" ]; then
  echo "TARGET not set correctly"
  exit 1
fi

cp "${SOURCE_FILE}" "${TEMP_FILE}"

sed -i.bak "/${heading} ${TARGET}/,\$!d" "${TEMP_FILE}"
sed -i.bak "s/${heading} ${TARGET}/${TARGET}/g" ${TEMP_FILE}
sed -i.bak "/^${heading} [a-zA-Z]/,\$d" ${TEMP_FILE}
sed -i.bak "s/##/#/g" ${TEMP_FILE}
sed -i.bak "s/# //g" ${TEMP_FILE}
sed -i.bak "s/#/\n/g" ${TEMP_FILE}

extract=$(jq -R -r -s -c '.' ${TEMP_FILE})
references=$(jq -r '.findings[].references' "${TARGET_FILE}")
echo "references: ${references}"

# heredoc for correctly-parsed newlines
extract=$(cat <<EOF
${extract}
${references}
EOF
)

echo $(jq --arg extract "${extract}" '.findings[].references = ($extract)' < "${TARGET_FILE}") > "${TARGET_FILE}"
