echo off
set op=%1
if %op%==1 goto uno
if %op%==2 goto dos

:uno
tasm /zi /l %2> errores.txt
if not exist "%2.obj" goto salirNEGRO
tlink /v %2 | pause
td %2 %3 %4 %5 %6 %7
echo off
goto SALIRBLANCO

:dos
tasm /zi /l %2 + %3 > errores.txt
if not exist "%2.obj" goto salirNEGRO
tlink /v %2 + %3
td %2 %3 %4 %5 %6 %7
echo off
goto SALIRBLANCO

:salirNEGRO
echo se produjo errores... mire el archivo ERRORES.txt

:SALIRBLANCO