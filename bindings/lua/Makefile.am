LIBVERSION = 0:1:0

if ENABLE_DEBUG
AM_CFLAGS_EXTRA= -DRS232_DEBUG -ggdb3 -O0
else
AM_CFLAGS_EXTRA = -O2
endif

INCLUDES = $(all_includes) -I$(top_srcdir)/include
AM_CFLAGS = -Wall -ansi -pedantic -W -Wmissing-prototypes -Wmissing-declarations -Werror -Wno-unused-but-set-variable -std=gnu99 $(AM_CFLAGS_EXTRA) $(LUA_CFLAGS)

lib_LTLIBRARIES = luars232.la
luars232_la_LIBADD = ../../src/librs232.la $(LUA_LFLAGS)
luars232_la_LDFLAGS = -Wc,-nostartfiles -version-info $(LIBVERSION) -module
luars232_la_SOURCES = luars232.c

