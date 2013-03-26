@echo off
set MINGW_BIN=d:\MinGW\bin
set CMAKE_BIN=d:\MinGW\CMake 2.8\bin
set PATH=%MINGW_BIN%;%CMAKE_BIN%;%PATH%

del /f /s /q build\mingw
mkdir build\mingw
cd build\mingw

cmake -G "MinGW Makefiles" -DUNIT_TESTING=on -DLUA_BINDINGS:bool=on -DCMOCKA_BIN_DIR:path="d:/projekty/vc/cmocka/vs2010/bin" -DCMOCKA_INCLUDE_DIR:path="d:\projekty\vc\cmocka\vs2010\include" -DCMOCKA_LIBRARY="d:\projekty\vc\cmocka\vs2010\lib\cmocka.lib" -DLUA_LIBRARY:filepath="h:\Lua\5.1\lib\lua51.lib" -DLUA_INCLUDE_DIR:path="h:\Lua\5.1\include" ..\..

make package package_source
cd ..\..
