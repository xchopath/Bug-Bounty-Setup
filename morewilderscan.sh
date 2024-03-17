#!/usr/bin/env bash
# Run: bash morewilderscan.sh list.txt

##################################################
##### MoreWilder (Wildcard) Domain List Scan #####
##################################################

TARGET_LIST="${1}"
RESULT_PATH="$(pwd)/scan-result"
MAX_PROCESS=10

if [[ ! -d ${RESULT_PATH} ]]; then
	mkdir ${RESULT_PATH}
fi

function wildcardscan() {
	TARGET="${1}"

	SUBFINDER_OUTPUT="${RESULT_PATH}/subfinder_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"
	HTTPX_OUTPUT="${RESULT_PATH}/httpx_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"
	NUCLEI_OUTPUT="${RESULT_PATH}/nuclei_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"
	URLDUMP_OUTPUT="${RESULT_PATH}/urldump_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"

	subfinder -silent -d ${TARGET} -o ${SUBFINDER_OUTPUT}
	if [[ $(cat ${SUBFINDER_OUTPUT} | wc -l) -eq 0 ]]; then
		rm ${SUBFINDER_OUTPUT}
		return 0
	fi

	cat ${SUBFINDER_OUTPUT} | httpx -silent | tee -a ${HTTPX_OUTPUT}
	if [[ $(cat ${HTTPX_OUTPUT} | wc -l) -eq 0 ]]; then
		rm ${HTTPX_OUTPUT}
		return 0
	fi

	for HTTP in $(cat ${HTTPX_OUTPUT})
	do
		urldump ${HTTP} | tee -a ${URLDUMP_OUTPUT}
		gowitness single ${HTTP} -P ${RESULT_PATH}
	done

	nuclei -t http/cves,http/exposures,http/exposed-panels,http/technologies,http/takeovers,http/default-logins -list ${HTTPX_OUTPUT} -o ${NUCLEI_OUTPUT}
	if [[ $(cat ${NUCLEI_OUTPUT} | wc -l) -eq 0 ]]; then
		rm ${NUCLEI_OUTPUT}
		exit
	fi
}

if [[ ! -f ${TARGET_LIST} ]]; then
	echo "[ERROR] Please use correct command"
	echo "   Example: ${0} list.txt"
	exit
fi

(
	for DOMAIN in $(cat ${TARGET_LIST})
	do
		((PROCESS_NUMBER=PROCESS_NUMBER%MAX_PROCESS)); ((PROCESS_NUMBER++==0)) && wait
		wildcardscan "${DOMAIN}" &
	done
	wait
)
