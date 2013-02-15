#
# Cross compile using Poky prebuilt toolchains, you need to source the
# environment first:
#
# $ rm -fr build; mkdir build; cd build
# $ source /home/ynezz/dev/poky/1.3/environment-setup-armv5te-poky-linux-gnueabi
# $ cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchains/poky.cmake
# $ make
#

SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 1)

#
# TODO - meh, can't get it compile with those two set, linker bombs out on missing libgcc
#
# SET(CMAKE_C_COMPILER ${CROSS_TOOL_ROOT}/arm-poky-linux-gnueabi-gcc)
# SET(CMAKE_CXX_COMPILER ${CROSS_TOOL_ROOT}/arm-poky-linux-gnueabi-g++)
#

SET(CMAKE_FIND_ROOT_PATH $ENV{OECORE_TARGET_SYSROOT})
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
