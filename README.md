# Renegade X scripts

> [!CAUTION]
> These scripts are not official and I am not affiliated with Totem Arts.
>
> Please be cautious and thoroughly evaluate scripts before executing them.

## [ren-x-patcher.sh](https://github.com/r1c0ch3t/ren-x-scripts/blob/main/ren-x-patcher.sh)

Verifies, downloads and patches game files. Default installation path is **~/Games/Renegade X/**. You can change it by modifying **RENX_INSTALL_PATH** variable.

### Dependencies

 - [jq](https://github.com/jqlang/jq)
 - [xdelta](https://github.com/jmacd/xdelta)

These should be available in your distro's repositories.

## [run.sh](https://github.com/r1c0ch3t/ren-x-scripts/blob/main/run.sh)

Launches the game using Proton 8. You need to [install](steam://launch/2348590) it via Steam.

You might also need [d3dcompiler_47.dll](https://lutris.net/files/tools/dll/d3dcompiler_47.dll) to compile shaders on first launch. Put it in **Renegade X/Binaries/Win64** folder.
