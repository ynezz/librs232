# vim: set ts=8 noet:

if(LUA_BINDINGS)
	message(STATUS "Building Lua bindings")
	add_subdirectory(lua)
endif()
