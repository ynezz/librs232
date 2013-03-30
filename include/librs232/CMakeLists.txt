# vim: set ts=8 noet:

set(rs232_HDRS rs232.h version.h)

INSTALL(
	FILES
    	${rs232_HDRS}
	DESTINATION
		${INCLUDE_INSTALL_DIR}/${PROJECT_NAME}
)
