include_directories(${CMAKE_SOURCE_DIR}/include ${CMOCKA_INCLUDE_DIR})
add_cmocka_test(cmocka-test-basic test-basic.c librs232 ${CMOCKA_LIBRARY})
if(WIN32)
	set_tests_properties(cmocka-test-basic PROPERTIES ENVIRONMENT "PATH=${CMAKE_BINARY_DIR}/src;${CMOCKA_BIN_DIR};$ENV{PATH}")
	# since the CMOCKA_BIN_DIR in the path doesn't work for cmocka.dll we copy that DLL over to the binary dir
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMOCKA_BIN_DIR}/cmocka.dll" "${CMAKE_BINARY_DIR}/tests/cmocka" OUTPUT_QUIET ERROR_QUIET)
endif()
