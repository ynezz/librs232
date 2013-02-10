#include "afxres.h"

VS_VERSION_INFO VERSIONINFO
FILEVERSION ${LIB_VERSION_MAJOR},${LIB_VERSION_MINOR},${LIB_VERSION_PATCH},${LIB_VERSION_LUA}
 PRODUCTVERSION ${LIB_VERSION_MAJOR},${LIB_VERSION_MINOR},${LIB_VERSION_PATCH},${LIB_VERSION_LUA}
 FILEFLAGSMASK 0x17L
#ifdef _DEBUG
 FILEFLAGS 0x1L
#else
 FILEFLAGS 0x0L
#endif
 FILEOS 0x4L
 FILETYPE 0x2L
 FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "000004b0"
        BEGIN
            VALUE "CompanyName", "Petr Stetiar, Gaben Ltd.\0"
            VALUE "FileDescription", "luars232 - Lua library for serial communication over RS232\0"
	    VALUE "FileVersion", "${LIB_VERSION_MAJOR},${LIB_VERSION_MINOR},${LIB_VERSION_PATCH},${LIB_VERSION_LUA}\0"
            VALUE "InternalName", "luars232\0"
            VALUE "LegalCopyright", "Copyright (c) 2013 Petr Stetiar, Gaben Ltd.\0"
            VALUE "OriginalFilename", "luars232.dll\0"
            VALUE "ProductName", "luars232 - Library for serial communication over RS232\0"
	    VALUE "ProductVersion", "${LIB_VERSION_MAJOR},${LIB_VERSION_MINOR},${LIB_VERSION_PATCH},${LIB_VERSION_LUA}\0"
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x0, 1200
    END
END
