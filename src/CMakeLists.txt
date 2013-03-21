# vim: set ts=8 noet:

set(RS232_LIBRARY ${PROJECT_NAME})
include_directories(${CMAKE_SOURCE_DIR}/include)

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Werror")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror")
endif()

set(lib_SRCS rs232.c)
if(WIN32)
	configure_file(librs232.rc.cmake librs232.rc)
	set(RC_FILE librs232.rc)
	list(APPEND lib_SRCS rs232_windows.c)
	add_definitions(-DRS232_EXPORT -DUNICODE -D_UNICODE)
else(WIN32)
	list(APPEND lib_SRCS rs232_posix.c)
endif(WIN32)

add_library(rs232 STATIC ${lib_SRCS})
add_library(${RS232_LIBRARY} SHARED rs232 ${RC_FILE})

# pkg-config file
configure_file(librs232.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/librs232.pc)
install(
	FILES
		${CMAKE_CURRENT_BINARY_DIR}/librs232.pc
	DESTINATION
		${LIB_INSTALL_DIR}/pkgconfig
	COMPONENT
		pkgconfig
)

set_target_properties(
	${RS232_LIBRARY}
	PROPERTIES
		PREFIX
			""
		VERSION
			${LIBRARY_VERSION}
		SOVERSION
			${LIBRARY_SOVERSION}
)

install(
	TARGETS
		${RS232_LIBRARY}
	LIBRARY DESTINATION
		${LIB_INSTALL_DIR}
	ARCHIVE DESTINATION
		${LIB_INSTALL_DIR}
	RUNTIME DESTINATION
		${BIN_INSTALL_DIR}
)

add_subdirectory(bindings)
