@echo off
set "HURLUI_TERM=neovide"      REM CHANGE THIS if you are using another terminal or set to nothing if you want it to run in the current terminal
set "OUTPUT_BASE=C:\Temp\hurlui"  REM CHANGE THIS if you want your queries to be persistent
set "DEFAULT_ENVSPACE_NAME=dev"  REM CHANGE THIS if you want your queries to be persistent

set "HURLUI_HOME=%~dp0."

REM Set environment variables for nvim
set "NV_HURLUI_DATA=%LOCALAPPDATA%"
set "NV_HURLUI_CACHE=%LOCALAPPDATA%\Temp"
set "PATH=%PATH%;%HURLUI_HOME%"

REM Create the output base directory if it doesn't exist
if not exist "%OUTPUT_BASE%" (
    mkdir "%OUTPUT_BASE%"
)

REM Uncomment the following lines if you need to create directories and files for envspace:
REM if not exist "%CD%\.envs" (
REM     mkdir "%CD%\.envs"
REM )

REM if not exist "%CD%\.envs\%DEFAULT_ENVSPACE_NAME%" (
REM     type nul > "%CD%\.envs\%DEFAULT_ENVSPACE_NAME%"
REM )

REM Please note that batch scripts don't directly support running nvim like in PowerShell.
REM The equivalent command in batch is simply 'nvim' (if you have neovim installed) or 'vim'.
REM You can adjust the parameters accordingly for your specific use case.

neovide -- -u "%HURLUI_HOME%\init.lua" %*
