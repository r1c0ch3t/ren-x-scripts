#!/bin/bash

: "${RENX_INSTALL_PATH:="$HOME/Games/Renegade X/"}"
: "${STEAM_INSTALL_PATH:="$HOME/.local/share/Steam"}"
: "${COMPAT_DATA_PATH:="${RENX_INSTALL_PATH}/.proton"}"
mkdir -p "${COMPAT_DATA_PATH}"

DEF_CMD=("${RENX_INSTALL_PATH}/Binaries/Win64/UDK.exe" "$@" "-nomovies" "-useallavailablecores")
STEAM_COMPAT_DATA_PATH="${COMPAT_DATA_PATH}" \
STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAM_INSTALL_PATH}" \
SteamAppId="13260" \
PROTON_NO_ESYNC=1 \
PROTON_NO_GLSL=1 \
PROTON_USE_D9VK=1 \
"${STEAM_INSTALL_PATH}/steamapps/common/Proton - Experimental/proton" run "${DEF_CMD[@]}"
