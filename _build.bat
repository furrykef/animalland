@echo off
chars.py || goto error
pwgen.py || goto error
C:\MFS\tniasm\tniasm multibank.asm multibank.out || goto error
copy tniasm.sym multibank.sym || goto error
C:\MFS\tniasm\tniasm animalhack.asm animalhacke.rom || goto error
"C:\Games\romhack\tools\text tools\Atlas-1.11\atlas" animalhacke.rom animalhack-script.txt || goto error
goto end
:error
echo There were errors.
:end
pause
