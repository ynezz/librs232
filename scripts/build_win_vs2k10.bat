@echo off
set CMAKE_BIN="d:\MinGW\CMake 2.8\bin"
set PATH=%CMAKE_BIN%;c:\windows\system32;%PATH%

del /f /s /q build\vs2k10 > NUL
mkdir build\vs2k10
cd build\vs2k10

@call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
cmake -G "NMake Makefiles" -DUNIT_TESTING=on -DLUA_BINDINGS:bool=on -DCMOCKA_BIN_DIR:path="d:/projekty/vc/cmocka/vs2010/bin" -DCMOCKA_INCLUDE_DIR:path="d:\projekty\vc\cmocka\vs2010\include" -DCMOCKA_LIBRARY="d:\projekty\vc\cmocka\vs2010\lib\cmocka.lib" -DLUA_LIBRARY:filepath="h:\Lua\5.1\lib\lua51.lib" -DLUA_INCLUDE_DIR:path="h:\Lua\5.1\include" ..\..

nmake all test package package_source
cd ..\..
