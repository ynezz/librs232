AUTOMAKE_OPTIONS = foreign 1.6
SUBDIRS = include src bindings

$(OBJECTS): libtool
libtool: $(LIBTOOL_DEPS)
	$(SHELL) ./config.status --recheck

EXTRA_DIST = windows/vs2k5/librs232/*

