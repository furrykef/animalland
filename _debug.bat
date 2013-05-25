@echo off
set OLDCD=%CD%
cd \Games\MESS
mess64 -debug cf1200 "%OLDCD%\animalhacke.rom"
rem mess64 -rp "C:\Games\MSX\Animal Land\Animal Hack;C:\Games\MESS\roms" -debug cf1200 animllnd
pause
