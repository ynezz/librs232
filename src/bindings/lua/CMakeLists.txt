# vim: set ts=8 noet:

find_package(Lua51 REQUIRED)

set(lib_SRCS luars232.c)
if(WIN32)
	configure_file(luars232.rc.cmake luars232.rc)
	list(APPEND lib_SRCS luars232.rc)
endif()

add_library(luars232 MODULE ${lib_SRCS} )
target_link_libraries(luars232 ${LUA_LIBRARY} rs232)
set_target_properties(luars232 PROPERTIES PREFIX "")
include_directories(${LUA_INCLUDE_DIR})

install(
	TARGETS
		luars232
	DESTINATION
		lua
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
