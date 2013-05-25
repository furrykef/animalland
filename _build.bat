@echo off
rem copy animalland-expanded.rom animalhacke.rom
C:\MFS\tniasm\tniasm animalhack.asm animalhacke.rom
if errorlevel 1 goto error
"C:\Games\romhack\tools\text tools\Atlas-1.11\atlas" animalhacke.rom animalhack-script.txt
if not errorlevel 1 goto end
:error
echo There were errors.
:end
pause
