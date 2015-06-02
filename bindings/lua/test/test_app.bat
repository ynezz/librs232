@Echo Off

:: Now we declare a scope
Setlocal EnableDelayedExpansion EnableExtensions

start lua testsrv.lua
echo --------------------------------------
echo server started
echo --------------------------------------

sleep 30
lua utestcli.lua

set code=%errorlevel%

echo --------------------------------------
echo Exit %code%
echo --------------------------------------

taskkill /F /IM lua.exe
sleep 30

start lua testsrv_rs232.lua
echo --------------------------------------
echo server started
echo --------------------------------------

sleep 30
lua utestcli_rs232.lua

if "%code%"=="0" (
	set code=%errorlevel%
)

echo --------------------------------------
echo Exit %code%
echo --------------------------------------

exit /B %code%
