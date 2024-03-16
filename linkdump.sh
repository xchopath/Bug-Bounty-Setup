#!/usr/bin/env bash

TARGET="${1}"

OUTPUT="$(pwd)/linkdump_$(date +"%Y%m%d")_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"

KATANA_FID=$(echo "$(shuf -i 10000-99999 | head -1) `date`" | md5sum | awk '{print $1}')
GAU_FID=$(echo "$(shuf -i 10000-99999 | head -1) `date`" | md5sum | awk '{print $1}')

katana -u ${TARGET} -d 5 -sc -o /tmp/${KATANA_FID}
gau ${TARGET} --o /tmp/${GAU_FID}

cat /tmp/${KATANA_FID} >> ${OUTPUT}
cat /tmp/${GAU_FID} >> ${OUTPUT}

rm /tmp/${KATANA_FID}
rm /tmp/${GAU_FID}
