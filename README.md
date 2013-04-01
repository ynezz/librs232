librs232
========
Multiplatform library for serious serial communication using RS-232 standard.

License
-------
This library is released under [The MIT License (MIT)](http://opensource.org/licenses/MIT).

Authors
-------
Please see [AUTHORS](https://github.com/ynezz/librs232/blob/next/AUTHORS) file.

Features
--------
* easy to use
* liberal license
* supports multiple platforms
* offers Lua bindings so your next protocol mocking should be just a breeze

Dependencies
------------
* Build: CMake 2.6 or higher
* Needed for testing:
  * [cmocka](http://cmocka.cryptomilk.org)
  * [cram](https://bitheap.org/cram)

            $ sudo apt-get install python-pip
            $ sudo pip install cram
            
Building
--------
* Linux & OSX

        $ git clone git://github.com/ynezz/librs232.git
        $ mkdir librs232/build && cd librs232/build
        $ cmake ..
        $ make install

* Windows

        $ git clone git://github.com/ynezz/librs232.git
        $ cd librs232
        $ scripts/build_win_mingw.bat (or scripts/build_vs2k10.bat)
        
##### CMake build options
* *WITH_LOGGING* - Build with logging support, default: ON
* *WITH_DEBUG_LOGGING* - Build with debug logging support, default: OFF
* *LUA_BINDINGS* - Build with Lua bindings, default: OFF
* *LUA_RS232_STATIC* - Build Lua bindings with librs232 compiled in statically, default: OFF
* *UNIT_TESTING* - Build and run unit tests, default: OFF
* *UNIT_TESTING_PORT_NAME1* - Serial port1 used for testing, default: None
* *CMOCKA_BIN_DIR* - Directory with cmocka.dll - used for testing on Windows only, default: None

Support requests & Bug reporting
--------------------------------
Please kindly use neat GitHub's [issue feature](https://github.com/ynezz/librs232/issues/new).
Do not ever try to contact the author with support requests directly via email.
Those emails are just simply blackholed.

For bugs, features etc. just simply summon a pull request with fix over GitHub also :-)

Quality Insurance
-----------------
Every release is build tested on the following build matrix:

* Linux: Ubuntu (12.04 LTS) x64 and Debian (Wheezy and Sid) x86/x64
* Linux cross: Debian host ARMv5T (Poky toolchain) and MIPS32 (OpenWRT toolchain)
* Linux cross: Ubuntu 12.04 LTS x64 host with MinGW (gcc-mingw32 toolchain)
* Windows: VS2005, VS2010 (on Windows 7 x64 host), MinGW
* OSX Lion

In addition, every release is also being run tested on the following hosts:

* Linux Ubuntu 12.04 LTS x64 (incl. real HW test)
* Linux Debian Wheezy (incl. real HW test) 
* OSX Lion (incl. real HW test)
* Windows 7 x64

I'm using [Jenkins](jenkins-ci.org) for the QA/CI, so this build/testing matrix is actually run
after every commit. 

Todo
----
* documentation (of course)

  To be honest, I wanted to write something, but I couldn't find an easy way to write
  a docs for the C and Lua part with one tool. I've just evaluated few of them
  and I'll probably go the Sphinx route, but as it seems now, I would need to figure out the
  Lua part first (C part seems to be already baked in).
