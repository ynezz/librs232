if ENABLE_DEBUG
AM_CFLAGS_EXTRA= -DRS232_DEBUG -ggdb3 -O0
else
AM_CFLAGS_EXTRA = -O2
endif

AM_CPPFLAGS = $(all_includes) -I$(top_srcdir)/include -Wall -ansi -pedantic -W -Wmissing-prototypes -Wmissing-declarations -Werror -Wno-unused-but-set-variable -std=gnu99 $(AM_CFLAGS_EXTRA) $(LUA_CFLAGS) $(LUA_INCLUDE)

luaexec_LTLIBRARIES = luars232.la
luars232_la_LIBADD = ../../src/librs232.la $(LUA_LFLAGS) $(LUA_LIB)
luars232_la_LDFLAGS = -Wc,-nostartfiles -avoid-version -module
luars232_la_SOURCES = luars232.c

