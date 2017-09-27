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
AC_INIT([librs232], [1.0.3], [ynezz@true.cz])
AM_INIT_AUTOMAKE([1.8 foreign])
AC_PROG_CC
AM_PROG_CC_C_O
AC_C_CONST
AC_EXEEXT
LT_INIT()
AC_SUBST(LIBTOOL_DEPS)

AC_ARG_ENABLE(lua,          [  --disable-lua             Turn off building of Lua library  (default=compiled if found)],enable_lua=$enableval,enable_lua=yes)

AC_ARG_ENABLE(debug,
	[  --enable-debug      Enable debug],
	[ENABLE_DEBUG=1], [ENABLE_DEBUG=0])
AM_CONDITIONAL(ENABLE_DEBUG, test "$ENABLE_DEBUG" == "1")

# Lua

if test "x$enable_lua" = "xyes" ; then
    AX_PROG_LUA(5.1, 5.4)
    AX_LUA_HEADERS
    AX_LUA_LIBS
    AC_CONFIG_MACRO_DIR(m4)
    AC_DEFINE(BUILD_LUA)
fi

AM_CONDITIONAL(BUILD_LUA,     test "$enable_lua" = "yes")

# Lua end

AC_ARG_WITH()
AC_OUTPUT(Makefile src/Makefile bindings/Makefile bindings/lua/Makefile include/Makefile include/librs232/Makefile src/librs232.pc)

AC_MSG_RESULT([])
AC_MSG_RESULT([ $PACKAGE version $VERSION configured successfully.])
AC_MSG_RESULT([])
AC_MSG_RESULT([Using '$prefix' for installation.])
AC_MSG_RESULT([])
