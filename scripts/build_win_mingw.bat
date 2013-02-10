@echo off
set MINGW_BIN=d:\MinGW\bin
set CMAKE_BIN=d:\MinGW\CMake 2.8\bin
set PATH=%MINGW_BIN%;%CMAKE_BIN%;%PATH%

del /f /s /q build\mingw
mkdir build\mingw
cd build\mingw

cmake -G "MinGW Makefiles" -DLUA_BINDINGS:bool=on -DLUA_LIBRARY:string="h:\Lua\5.1\lib\lua51.lib" -DLUA_INCLUDE_DIR:string="h:\Lua\5.1\include" ..\..

make package package_source
cd ..\..
