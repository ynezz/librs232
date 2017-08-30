@Echo Off

:: Now we declare a scope
Setlocal EnableDelayedExpansion EnableExtensions

start cmd /c lua testsrv.lua ^> testsrv.log 2^>^&1
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
type testsrv.log
sleep 30

start cmd /c lua testsrv_rs232.lua ^> testsrv.log 2^>^&1
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

taskkill /F /IM lua.exe
type testsrv.log
sleep 30

echo --------------------------------------
echo test gc
echo --------------------------------------

lua test_gc.lua

if "%code%"=="0" (
	set code=%errorlevel%
)

exit /B %code%
