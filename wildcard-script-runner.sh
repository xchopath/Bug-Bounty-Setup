#!/usr/bin/env bash

SCRIPT="${1}"

for TARGET in $(cat h1-scopes.txt | grep 'scope:true' | grep ' \*\.' | awk -F '|' '{print $2}' | sed 's/,/ /g' | sed 's/\*\.//g')
do
	eval ${SCRIPT} "${TARGET}"
done
