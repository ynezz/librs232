@echo off
set CMAKE_BIN="d:\MinGW\CMake 2.8\bin"
set PATH=%CMAKE_BIN%;c:\windows\system32;%PATH%

del /f /s /q build\vs2k10
mkdir build\vs2k10
cd build\vs2k10

@call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
cmake -G "NMake Makefiles" -DLUA_BINDINGS:bool=on -DLUA_LIBRARY:string="h:\Lua\5.1\lib\lua51.lib" -DLUA_INCLUDE_DIR:string="h:\Lua\5.1\include" ..\..

nmake package package_source
cd ..\..
