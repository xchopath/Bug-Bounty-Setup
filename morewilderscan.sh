#!/usr/bin/env bash
# Run: bash morewilderscan.sh list.txt

##################################################
##### MoreWilder (Wildcard) Domain List Scan #####
##################################################

TARGET_LIST="${1}"
RESULT_PATH="$(pwd)/scan-result"
MAX_PROCESS=5

if [[ ! -d ${RESULT_PATH} ]]; then
	mkdir ${RESULT_PATH}
fi

#############################
##### URL DUMP FUNCTION #####
#############################
function urldump() {
	TARGET="${1}"
	URLDUMP_OUTPUT="/tmp/urldump_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"
	KATANA_FID=$(echo "$(shuf -i 10000-99999 | head -1) `date`" | md5sum | awk '{print $1}')
	GAU_FID=$(echo "$(shuf -i 10000-99999 | head -1) `date`" | md5sum | awk '{print $1}')
	katana -u ${TARGET} -d 5 -sc -o /tmp/${KATANA_FID}
	gau ${TARGET} --blacklist png,jpg,jpeg,gif,mp3,mp4,svg,woff,woff2,etf,eof,otf,css,exe,ttf,eot --o /tmp/${GAU_FID}
	cat /tmp/${KATANA_FID} >> ${URLDUMP_OUTPUT}
	cat /tmp/${GAU_FID} >> ${URLDUMP_OUTPUT}
	rm /tmp/${KATANA_FID}
	rm /tmp/${GAU_FID}
	cat ${URLDUMP_OUTPUT} | sort -V | uniq
	rm ${URLDUMP_OUTPUT}
}

#########################
##### Wildcard Scan #####
#########################
function wildcardscan() {
	TARGET="${1}"

	SUBFINDER_OUTPUT="${RESULT_PATH}/$(date +"%Y%m%d%H%M")_subfinder_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"
	HTTPX_OUTPUT="${RESULT_PATH}/$(date +"%Y%m%d%H%M")_httpx_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"
	NUCLEI_OUTPUT="${RESULT_PATH}/$(date +"%Y%m%d%H%M")_nuclei_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"
	URLDUMP_OUTPUT="${RESULT_PATH}/$(date +"%Y%m%d%H%M")_urldump_$(echo "${TARGET}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').txt"

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
		if [[ $(cat ${URLDUMP_OUTPUT} | wc -l) -eq 0 ]]; then
			rm ${URLDUMP_OUTPUT}
			exit
		fi
		XRAY_OUTPUT="${RESULT_PATH}/$(date +"%Y%m%d%H%M")_xray_$(echo "${HTTP}" | sed 's/\./_/g' | sed 's/:/_/g' | grep -o '[a-zA-Z0-9_]' | sed ':a;N;$!ba;s/\n//g').html"
		./xray webscan --url ${HTTP} --html-output ${XRAY_OUTPUT}
	done

	nuclei -t http/cves,http/exposures,http/exposed-panels,http/technologies,http/takeovers,http/default-logins -list ${HTTPX_OUTPUT} -o ${NUCLEI_OUTPUT}
	if [[ $(cat ${NUCLEI_OUTPUT} | wc -l) -eq 0 ]]; then
		rm ${NUCLEI_OUTPUT}
		exit
	fi
}

################
##### MAIN #####
################
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
