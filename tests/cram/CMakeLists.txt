find_program(
	CRAM_EXECUTABLE
	NAMES cram
	HINTS
		/usr/local/share/python
		ENV CRAM_DIR
	PATH_SUFFIXES bin
)

if(CRAM_EXECUTABLE)
	if(LUA_BINDINGS)
		file(GLOB LUA_NOHW_TESTS "lua-nohw-*.t")
		add_test(cram-lua-nohw-tests ${CRAM_EXECUTABLE} -v ${LUA_NOHW_TESTS})
		set_tests_properties(cram-lua-nohw-tests PROPERTIES ENVIRONMENT "LUA_CPATH=${CMAKE_BINARY_DIR}/src/bindings/lua/?.so")

		if(UNIT_TESTING_PORT_NAME1)

			# Temporary workaround for Jenkins as I need to figure
			# out how to do this properly between platforms...
			if(APPLE)
				set(UNIT_TESTING_PORT_NAME1 "/dev/cu.serial1")
			endif()

			file(GLOB LUA_HW_TESTS "lua-hw-*.t")
			add_test(cram-lua-hw-tests ${CRAM_EXECUTABLE} -v ${LUA_HW_TESTS})
                        set_tests_properties(cram-lua-hw-tests PROPERTIES ENVIRONMENT "LUA_CPATH=${CMAKE_BINARY_DIR}/src/bindings/lua/?.so")
                        set_property(TEST cram-lua-hw-tests APPEND PROPERTY ENVIRONMENT "LUA_RS232_PORT_NAME=${UNIT_TESTING_PORT_NAME1}")
		endif()
	endif()
endif()
