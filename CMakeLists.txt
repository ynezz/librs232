# vim: set ts=8 noet:

project(librs232 C)

cmake_minimum_required(VERSION 2.6)

# Stick to gcc on OSX as I can't grasp the clang's compiler messages yet
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	SET(CMAKE_C_COMPILER /usr/bin/gcc)
	SET(CMAKE_CXX_COMPILER /usr/bin/g++)
endif()

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

if(WITH_LOGGING)
	add_definitions(-DRS232_WITH_LOGGING)
	if(WITH_DEBUG_LOGGING)
		add_definitions(-DRS232_DEBUG_LOGGING)
	endif()
endif()

configure_file(${CMAKE_SOURCE_DIR}/include/librs232/version.h.cmake ${CMAKE_SOURCE_DIR}/include/librs232/version.h)
add_subdirectory(include)
add_subdirectory(src)

if(UNIT_TESTING)
	enable_testing()
	add_subdirectory(tests)
endif()
