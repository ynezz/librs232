find_package(CMocka)
if(CMOCKA_FOUND)
	include(AddCMockaTest)
	add_subdirectory(cmocka)
endif()

add_subdirectory(cram)

include_directories(../include)
link_directories(${CMAKE_CURRENT_BINARY_DIR}/../src)

#
# Following macro and test inspiration stolen from http://github.com/redjack/libcork
# Copyright © 2011-2012, RedJack, LLC.
#
macro(make_test test_name)
    add_executable(shared-${test_name} ${test_name}.c)
    target_link_libraries(shared-${test_name} librs232)
    add_test(shared-${test_name} shared-${test_name})

    add_executable(embedded-${test_name} ${test_name}.c)
    target_link_libraries(embedded-${test_name} rs232_static)
    add_test(embedded-${test_name} embedded-${test_name})
endmacro(make_test)

make_test(test-basic)
