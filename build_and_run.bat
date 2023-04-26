@echo off
taskkill /IM "X4.exe" /F
call "C:\Programs\X4_Customizer_v1.24.8\Cat_Pack.bat" . .\subst_01.cat
:: PUSHD "C:\Program Files (x86)\Steam\steamapps\common\X4 Foundations"
:: call "C:\Program Files (x86)\Steam\steamapps\common\X4 Foundations\X4.exe" -nocputhrottle -nosoundthrottle -skipintro -logfile x4.log -scriptlogfiles -debug all
:: POPD

call "C:\Program Files (x86)\Steam\steam.exe" steam://run/392160