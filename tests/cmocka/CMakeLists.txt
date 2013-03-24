include_directories(${CMAKE_SOURCE_DIR}/include)
add_cmocka_test(cmocka-test-basic test-basic.c librs232 ${CMOCKA_LIBRARY})
