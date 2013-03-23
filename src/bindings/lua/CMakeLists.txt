# vim: set ts=8 noet:

find_package(Lua51 REQUIRED)

set(lib_SRCS luars232.c)
if(WIN32)
	configure_file(luars232.rc.cmake luars232.rc)
	list(APPEND lib_SRCS luars232.rc)
endif()

if(UNIX)
	execute_process(COMMAND lua -e "print(package.cpath:match(\".*;(.*)/%?.so;.*\"))"
			OUTPUT_VARIABLE LUA_PACKAGE_CPATH
			OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

if(NOT LUA_PACKAGE_CPATH)
	set(LUA_PACKAGE_CPATH lua)
endif()

add_library(luars232 MODULE ${lib_SRCS})
set_target_properties(luars232 PROPERTIES PREFIX "")
if(LUA_RS232_STATIC)
	target_link_libraries(luars232 ${LUA_LIBRARY} rs232_static)
else()
	target_link_libraries(luars232 ${LUA_LIBRARY} ${RS232_LIBRARY})
endif()


include_directories(${LUA_INCLUDE_DIR})

install(
	TARGETS
		luars232
	DESTINATION
		${LUA_PACKAGE_CPATH}
	COMPONENT
		lua
)

install(
	FILES
		${CMAKE_SOURCE_DIR}/doc/example.lua
	DESTINATION
		lua
	COMPONENT
		lua
)
