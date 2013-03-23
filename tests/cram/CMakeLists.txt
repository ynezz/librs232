find_program(
	CRAM_EXECUTABLE
	NAMES cram
	HINTS ENV CRAM_DIR
	PATH_SUFFIXES bin
)

if(CRAM_EXECUTABLE)
	if(LUA_BINDINGS)
		add_test(cram-lua-tests ${CRAM_EXECUTABLE} -v ${CMAKE_CURRENT_SOURCE_DIR})
	endif()
endif()
