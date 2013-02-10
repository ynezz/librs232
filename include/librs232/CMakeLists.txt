# vim: set ts=8 noet:

set(rs232_HDRS rs232.h version.h)

if(WIN32)
	list(APPEND rs232_HDRS rs232_windows.h)
else()
	list(APPEND rs232_HDRS rs232_posix.h)
endif()

INSTALL(
	FILES
    	${rs232_HDRS}
	DESTINATION
		${INCLUDE_INSTALL_DIR}/${PROJECT_NAME}
)
