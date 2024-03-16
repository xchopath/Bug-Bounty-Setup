#!/usr/bin/env bash

TARGET="${1}"

SUBFINDER_OUTPUT="$(pwd)/subfinder_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"
HTTPX_OUTPUT="$(pwd)/httpx_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"
NUCLEI_OUTPUT="$(pwd)/nuclei_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"

subfinder -silent -d ${TARGET} -o ${SUBFINDER_OUTPUT}
if [[ $(cat ${SUBFINDER_OUTPUT} | wc -l) -eq 0 ]]; then
	exit
fi

cat ${SUBFINDER_OUTPUT} | httpx -silent | tee -a ${HTTPX_OUTPUT}
if [[ $(cat ${HTTPX_OUTPUT} | wc -l) -eq 0 ]]; then
	exit
fi

nuclei -t http/cves,http/exposures,http/exposed-panels,http/technologies,http/takeovers,http/default-logins -list ${HTTPX_OUTPUT} -o ${NUCLEI_OUTPUT}
