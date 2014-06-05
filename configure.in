#
# This file is part of librs232 library
# 
# Copyright (c) 2008-2009 Petr Stetiar <ynezz@true.cz>
#
# Lua autofoo by FlashCode <flashcode@flashtux.org>
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# version 2.1 as published by the Free Software Foundation.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
# 
#  $Id$
#

AC_PREREQ(2.61)
AC_INIT([librs232], [0.0.1], [ynezz@true.cz])
AM_INIT_AUTOMAKE([1.8 foreign])
AC_PROG_CC
AM_PROG_CC_C_O
AC_C_CONST
AC_EXEEXT
AM_PROG_LIBTOOL
AC_SUBST(LIBTOOL_DEPS)

AC_ARG_ENABLE(lua,          [  --disable-lua             Turn off building of Lua library  (default=compiled if found)],enable_lua=$enableval,enable_lua=yes)
AC_ARG_WITH(lua-inc,        [  --with-lua-inc=DIR,       Lua include files are in DIR (default=autodetect)],lua_inc=$withval,lua_inc='')
AC_ARG_WITH(lua-lib,        [  --with-lua-lib=DIR,       Lua library files are in DIR (default=autodetect)],lua_lib=$withval,lua_lib='')

AC_ARG_ENABLE(debug,
	[  --enable-debug      Enable debug],
	[ENABLE_DEBUG=1], [ENABLE_DEBUG=0])
AM_CONDITIONAL(ENABLE_DEBUG, test "$ENABLE_DEBUG" == "1")

# Lua
LUA_VERSION=

if test "x$enable_lua" = "xyes" ; then
    enable_plugins="yes"

    ac_save_CPPFLAGS="$CPPFLAGS"
    ac_save_CFLAGS="$CFLAGS"
    ac_save_LDFLAGS="$LDFLAGS"

    LUA_CFLAGS=""
    LUA_LFLAGS=""

    if test -n "$lua_inc"; then
       CFLAGS="$CFLAGS -I$lua_inc"
       CPPFLAGS="$CPPFLAGS -I$lua_inc"
    fi
    if test -n "$lua_lib"; then
       LDFLAGS="$LDFLAGS -L$lua_lib"
    fi
    
    if test "x$LUA_CFLAGS" = "x" -o "x$LUA_LFLAGS" = "x" ; then
        PKGCONFIG=""
        AC_CHECK_PROGS(PKGCONFIG, pkg-config)
        if test "x$PKGCONFIG" != "x"; then
	    AC_MSG_CHECKING(for Lua headers and librairies with pkg-config)
	    echo
	    for l in "$lua_suffix" "" "51" "5.1" "50" "5.0" ; do
	        pkgconfig_lua_found=`$PKGCONFIG --exists lua$l 2>/dev/null`
	        if test "x$?" = "x0" ; then
		    LUA_VERSION=`$PKGCONFIG --modversion lua$l`
                    LUA_CFLAGS="$LUA_CFLAGS "`$PKGCONFIG --cflags lua$l`
                    LUA_LFLAGS="$LUA_LFLAGS "`$PKGCONFIG --libs lua$l`

		    pkgconfig_lualib_found=`$PKGCONFIG --exists lualib$l 2>/dev/null`
		    if test  "x$?" = "x0"; then
		       LUA_CFLAGS="$LUA_CFLAGS "`$PKGCONFIG --cflags lualib$l`
		       LUA_LFLAGS="$LUA_LFLAGS "`$PKGCONFIG --libs lualib$l`
		    fi
                    break
                fi
            done
        fi
    fi    

    if test "x$LUA_CFLAGS" = "x" -o "x$LUA_LFLAGS" = "x" ; then
        LUACONFIG=""
        AC_CHECK_PROGS(LUACONFIG, lua-config lua-config51 lua-config5.1 lua-config50 lua-config5.0)
        if test "x$LUACONFIG" != "x" ; then
            AC_MSG_CHECKING(for Lua headers and librairies with lua-config)
	    echo
            LUA_CFLAGS=`$LUACONFIG --include`
            LUA_LFLAGS=`$LUACONFIG --libs`
	    LUA_VERSION="5.0.x"
        fi
    fi

    if test "x$LUA_CFLAGS" = "x" -o "x$LUA_LFLAGS" = "x" ; then       
        AC_MSG_CHECKING(for Lua headers and librairies)
	echo
        AC_CHECK_HEADER(lua.h,ac_found_lua_header="yes",ac_found_lua_header="no")
        AC_CHECK_HEADER(lualib.h,ac_found_liblua_header="yes",ac_found_liblua_header="no")
        if test "x$ac_found_lua_header" = "xyes" -a "x$ac_found_liblua_header" = "xyes"; then
            LUA_CFLAGS="$CFLAGS"
        fi
        LDFLAGS="$LDFLAGS -lm"
        for l in "$lua_suffix" "" "51" "5.1" "50" "5.0" ; do
            AC_CHECK_LIB(lua$l,lua_call,ac_found_lua_lib="yes",ac_found_lua_lib="no")
            if test "x$ac_found_lua_lib" = "xyes" ; then
	        LUA_VERSION=">=5.1.0"	       

	        LUA_LFLAGS="$LDFLAGS -llua$l -lm"
		
		ac2_save_LDFLAGS="$LDFLAGS"
		LDFLAGS="$LDFLAGS -llua$l -lm"		

		if echo "$host_os" | grep "^linux" 1>/dev/null 2>&1 ; then
		   LDFLAGS="$LDFLAGS -ldl"
		fi

		AC_CHECK_LIB(lualib$l,luaL_openlib,ac_found_liblua_lib="yes",ac_found_liblua_lib="no")
		if test "x$ac_found_liblua_lib" = "xyes" ; then
		   LUA_VERSION="5.0.x"
		   
		   LUA_LFLAGS="$LUA_LFLAGS -llualib$l"

		   if echo "$host_os" | grep "^linux" 1>/dev/null 2>&1 ; then
		      LUA_LFLAGS="$LUA_LFLAGS -ldl"
		   fi		   
		fi

		LDFLAGS="$ac2_save_LDFLAGS"
		break
	    fi
        done
    fi

    AC_MSG_CHECKING(for Lua compiling and linking)
    LUA_TEST=`LT=luatest.c ; echo "#include <lua.h>" > $LT;  echo "#include <lualib.h>" >> $LT; echo "int main() { luaopen_base((lua_State *)lua_open()); return 0; }" >> $LT ; $CC -Wall $LT -o $LT.out -lm $LUA_CFLAGS $LUA_LFLAGS $CFLAGS $LDFLAGS 1>/dev/null 2>&1 ; echo $?; rm -f $LT $LT.out 1>/dev/null 2>&1`
	AC_MSG_RESULT(yes)

    CFLAGS="$ac_save_CFLAGS"
    CPPFLAGS="$ac_save_CPPFLAGS"
    LDFLAGS="$ac_save_LDFLAGS"
fi

if test "x$enable_lua" = "xyes" ; then
    AC_SUBST(LUA_CFLAGS)
    AC_SUBST(LUA_LFLAGS)
    AC_DEFINE(BUILD_LUA)
fi

AM_CONDITIONAL(BUILD_LUA,     test "$enable_lua" = "yes")
# Lua end

AM_CONDITIONAL(BUILD_TEST, 1)

AC_ARG_WITH()
AC_OUTPUT(Makefile src/Makefile bindings/Makefile bindings/lua/Makefile include/Makefile include/librs232/Makefile src/librs232.pc)

AC_MSG_RESULT([])
AC_MSG_RESULT([ $PACKAGE version $VERSION configured successfully.])
AC_MSG_RESULT([])
AC_MSG_RESULT([Using '$prefix' for installation.])
AC_MSG_RESULT([])
