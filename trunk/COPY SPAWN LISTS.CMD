@echo off

REM This script is used to automatically copy the spawn list scripts to the garrysmod/settings/spawnlist folder.
REM You must execute this file after every SVN update to get the newest spawn scripts loaded by Gmod.
REM Don't modify this script unless you know what you're doing.

CD /D .
CD "settings/spawnlist/"
COPY /Y "*.txt" "../../../../settings/spawnlist"