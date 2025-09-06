#!/bin/bash

: "${RENX_INSTALL_PATH:="$HOME/Games/Renegade X/"}"
: "${MAX_PARALLEL:=4}"

get_best_mirror(){
	(
		for mirror_url in $(jq -rc '.game.mirrors[].url' <<< "$1")
		do
			mirror="${mirror_url%/}" && 
			ping -q -w 1 "${mirror#*://}" &>/dev/null && 
			curl -qfsS -w '%{speed_download} '"${mirror}/"'\n' -o /dev/null --url "${mirror}/10kb_file" &
		done
		wait
	) | sort -n | tail -1 | awk '{print $2}'
}

patch_full(){
	if wget -q -np -nH -N -R index.html -e robots=off "$1$2/full/$4" -P "${TMP_DIR}$2/full/"; then
		xdelta3 -d -f "${TMP_DIR}$2/full/$4"  "${RENX_INSTALL_PATH}$3"
		printf "Full"
	else
		printf "DOWNLOAD FAILED"
	fi
}
patch_delta(){
	if wget -q -np -nH -N -R index.html -e robots=off "$1$2/delta/$4_from_$5" -P "${TMP_DIR}$2/delta/"; then
		mkdir -p "$(dirname "${RENX_INSTALL_PATH}$2/patch/$3")"
		xdelta3 -d -f -n -s "${RENX_INSTALL_PATH}$3" "${TMP_DIR}$2/delta/$4_from_$5" "${TMP_DIR}$2/patch/$3"
		mv -f "${TMP_DIR}$2/patch/$3" "${RENX_INSTALL_PATH}$3"
		printf "Delta"
	else
		patch_full "$1" "$2" "$3" "$4"		
	fi
}

download_file(){
	full_path="$(jq -r '.Path' <<< "${1//\\\\//}")"
	mkdir -p "$(dirname "${RENX_INSTALL_PATH}${full_path}")"	
	oldhash=$(jq -r '.OldHash' <<< "$1")
	newhash=$(jq -r '.NewHash' <<< "$1")
	sha=$([ -f "${RENX_INSTALL_PATH}${full_path}" ] && sha256sum "${RENX_INSTALL_PATH}${full_path}" | awk '{print $1}')
	if [ "${newhash}" != "${sha^^}" ]; then
		if [ "${newhash}" != "null" ]; then
			if [ "${oldhash}" != "${sha^^}" ]; then
				result=$(patch_full "${best_mirror}" "${patch_path}" "${full_path}" "${newhash}")
			else
				result=$(patch_delta "${best_mirror}" "${patch_path}" "${full_path}" "${newhash}" "${oldhash}")
			fi
		else
			[ -f "${RENX_INSTALL_PATH}${full_path}" ] && rm "${RENX_INSTALL_PATH}${full_path}"
			result="Removed"
		fi
	else
		result="Verified"
	fi
	printf '%*s\r%s\n' "$(tput cols)" "${result}" "${full_path}"
	wait
}

release_json=$(curl -s 'http://version.totemarts.services/launcher_data/version/release.json')
patch_path=$(jq -r '.game.patch_path' <<< "${release_json}")
best_mirror="$(get_best_mirror "${release_json}")"
instructions_json=$(curl -s "${best_mirror}${patch_path}/instructions.json")
TMP_DIR="/var/tmp/RenX/"

for file in $(jq -c '.[]' <<< "${instructions_json}")
do
	((i=i%MAX_PARALLEL)); ((i++==0)) && wait
	download_file "${file}" & 
done
