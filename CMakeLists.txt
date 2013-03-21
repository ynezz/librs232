# vim: set ts=8 noet:

project(librs232 C)

cmake_minimum_required(VERSION 2.6)

set(LIB_VERSION_MAJOR "2")
set(LIB_VERSION_MINOR "0")
set(LIB_VERSION_PATCH "0")
set(LIB_VERSION_LUA "0")

set(LIBRARY_VERSION "${LIB_VERSION_MAJOR}.${LIB_VERSION_MINOR}.${LIB_VERSION_PATCH}")
set(LIBRARY_SOVERSION "0")

set(CMAKE_MODULE_PATH
	${CMAKE_SOURCE_DIR}/cmake
	${CMAKE_SOURCE_DIR}/cmake/modules)

include(DefineCMakeDefaults)
include(DefinePlatformDefaults)
include(DefineCompilerFlags)
include(DefineOptions)
include(CPackConfig)

include(DefineInstallationPaths)
# install .dlls to bin/
set(BIN_INSTALL_DIR "bin" CACHE PATH "-")

configure_file(${CMAKE_SOURCE_DIR}/include/librs232/version.h.cmake ${CMAKE_SOURCE_DIR}/include/librs232/version.h)
add_subdirectory(include)
add_subdirectory(src)

if(WITH_TESTING)
	find_package(CMocka REQUIRED)
	include(AddCMockaTest)
	add_subdirectory(tests)
endif()
