@echo off
setlocal
pushd "%~dp0"

set "GODOT=.tools\godot\Godot_v4.7.2-stable_win64.exe"

if not exist "%GODOT%" (
    echo [ERROR] Godot was not found:
    echo %CD%\%GODOT%
    echo.
    pause
    exit /b 1
)

"%GODOT%" --path "%CD%" %*
set "GAME_EXIT=%ERRORLEVEL%"

if not "%GAME_EXIT%"=="0" (
    echo.
    echo [ERROR] The game exited with code %GAME_EXIT%.
    pause
)

popd
exit /b %GAME_EXIT%

