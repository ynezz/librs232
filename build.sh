#!/bin/sh
make distclean
. autogen.sh
./configure --prefix=$PWD/bin --enable-debug
#./configure --prefix=$PWD/bin
make install
