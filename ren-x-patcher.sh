#!/bin/bash

RENX_INSTALL_PATH="$HOME/Games/Renegade X/"

get_best_mirror(){
	(
		for mirror_url in $(jq -rc '.game.mirrors[].url' <<< $1)
		do
			mirror=${mirror_url%/} && 
			ping -q -w 1 ${mirror#*://} &>/dev/null && 
			curl -qfsS -w '%{speed_download} '"${mirror}/"'\n' -o /dev/null --url "${mirror}/10kb_file" &
		done
		wait
	) | sort -n | tail -1 | awk '{print $2}'
}
patch_full(){
	if wget -np -nH -N -R index.html -e robots=off "${best_mirror}${patch_path}/full/${newhash}" -P "${RENX_INSTALL_PATH}${patch_path}/full/"; then
		xdelta3 -d -f "${RENX_INSTALL_PATH}${patch_path}/full/${newhash}"  "${RENX_INSTALL_PATH}${full_path}"
		printf "Full\n"
	else
		printf "\e[1mDOWNLOAD FAILED\n\e[0m"
	fi
}
patch_delta(){
	if wget -np -nH -N -R index.html -e robots=off "${best_mirror}${patch_path}/delta/${newhash}_from_${oldhash}" -P "$RENX_INSTALL_PATH$patch_path/delta/"; then
		mkdir -p "$(dirname "${RENX_INSTALL_PATH}${patch_path}/patch/${full_path}")"
		xdelta3 -d -f -n -s "${RENX_INSTALL_PATH}${full_path}" "${RENX_INSTALL_PATH}${patch_path}/delta/${newhash}_from_${oldhash}" "${RENX_INSTALL_PATH}${patch_path}/patch/${full_path}"
		mv -f "${RENX_INSTALL_PATH}${patch_path}/patch/${full_path}" "${RENX_INSTALL_PATH}${full_path}"
		printf "Delta\n"
	else
		patch_full		
	fi
}

release_json=$(curl -s 'https://static.ren-x.com/launcher_data/version/release.json')
patch_path=$(jq -r '.game.patch_path' <<< ${release_json})
best_mirror="$(get_best_mirror "${release_json}")"
instructions_json=$(curl -s "${best_mirror}${patch_path}/instructions.json")

for file in $(jq -c '.[]' <<< ${instructions_json})
do
	full_path="$(jq -r '.Path' <<< ${file//\\\\//})"
	mkdir -p "$(dirname "${RENX_INSTALL_PATH}${full_path}")"	
	oldhash=$(jq -r '.OldHash' <<< ${file})
	newhash=$(jq -r '.NewHash' <<< ${file})
	sha=$(sha256sum "${RENX_INSTALL_PATH}${full_path}" | awk '{print $1}'s)
	printf "\e[1m${RENX_INSTALL_PATH}${full_path}\n\e[0m"
	if [ "${newhash}" != "${sha^^}" ]; then
		if [ "${newhash}" != "null" ]; then
			if [ "${oldhash}" != "${sha^^}" ]; then
				patch_full
			else
				patch_delta
			fi
		else
			rm "${RENX_INSTALL_PATH}${full_path}"
			printf "Removed\n"
		fi
	else
		printf "Verified\n"
	fi
done
printf "\e[1mDelete downloaded patch files? (${RENX_INSTALL_PATH}${patch_path})\n\e[0m"
rm -rI "${RENX_INSTALL_PATH}${patch_path}"