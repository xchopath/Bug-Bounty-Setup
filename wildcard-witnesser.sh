#!/usr/bin/env bash
# gowitness server --address 0.0.0.0:31338 -P ~/witnessed-list/

RESULT_PATH="$(pwd)/witnessed-list"
MAX_PROCESS=10

if [[ ! -d ${RESULT_PATH} ]]; then
	mkdir ${RESULT_PATH}
fi

function wildcardwitnesser() {
	TARGET="${1}"

	SUBFINDER_OUTPUT="${RESULT_PATH}/$(date +"%Y%m%d%H%M")_subfinder_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"
	HTTPX_OUTPUT="${RESULT_PATH}/$(date +"%Y%m%d%H%M")_httpx_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"

	subfinder -silent -d ${TARGET} -o ${SUBFINDER_OUTPUT}
	if [[ $(cat ${SUBFINDER_OUTPUT} | wc -l) -eq 0 ]]; then
		rm ${SUBFINDER_OUTPUT}
		return 0
	fi

	cat ${SUBFINDER_OUTPUT} | httpx -silent -t 100 | tee -a ${HTTPX_OUTPUT}
	if [[ $(cat ${HTTPX_OUTPUT} | wc -l) -eq 0 ]]; then
		rm ${HTTPX_OUTPUT}
		return 0
	fi

	(
		for HTTP in $(cat ${HTTPX_OUTPUT})
		do
			((PROCESS_NUMBER=PROCESS_NUMBER%MAX_PROCESS)); ((PROCESS_NUMBER++==0)) && wait
			gowitness single ${HTTP} -P ${RESULT_PATH} &
		done
		wait
	)
}

wildcardwitnesser "${1}"
