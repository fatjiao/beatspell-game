@echo off
setlocal
pushd "%~dp0"
start "Beatspell" "BeatspellPlaytest.exe" --main-pack "BeatspellPlaytest.pck"
popd
