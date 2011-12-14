LIBVERSION = 0:1:0

if ENABLE_DEBUG
AM_CFLAGS_EXTRA= -DRS232_DEBUG -ggdb3 -O0
else
AM_CFLAGS_EXTRA = -O2
endif

INCLUDES = $(all_includes) -I$(top_srcdir)/include $(LUA_CFLAGS)
AM_CFLAGS = -Wall -ansi -pedantic -W -Wmissing-prototypes -Wmissing-declarations -Werror -std=gnu99 $(AM_CFLAGS_EXTRA)

lib_LTLIBRARIES = librs232.la
librs232_la_LDFLAGS = -Wc,-nostartfiles -version-info $(LIBVERSION)
librs232_la_SOURCES = rs232.c rs232_posix.c

if ENABLE_DEBUG
bin_PROGRAMS = rs232_test
rs232_test_SOURCES = rs232_test.c
rs232_test_LDADD = librs232.la
endif

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = librs232.pc
