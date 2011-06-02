#!/bin/sh
make distclean
. autogen.sh
#./configure --prefix=$PWD/inst-dbg --enable-debug
./configure --prefix=$PWD/inst
make install
