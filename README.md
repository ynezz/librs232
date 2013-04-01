librs232
========
Multiplatform library for serious serial communication using RS-232 standard.

License
-------
This library is release under [The MIT License (MIT)](http://opensource.org/licenses/MIT).

Authors
-------
Please see AUTHORS file.

Features
--------
* easy to use
* liberal license
* bug free (of course)
* developed with love
* supports multiple platforms
* has Lua bindings so your next protocol mocking is just a breeze

Todo
----
* documentation (of course)
  To be honest, I wanted to write something, but I couldn't find an easy way to write
  a docs for the C and Lua part with one tool. I've just evaluated few of them
  and I'll probably go the Sphinx route, but I would need to figure out the
  Lua part (C part seems to be already baked in).

Dependencies
------------
* Build
	* CMake 2.6+

* Testing
	* [cram](https://bitheap.org/cram) (for testing)

		$ sudo apt-get install python-pip
		$ sudo pip install cram

Support requests & Bug reporting
--------------------------------
Please kindly use neat GitHub's [issue feature](https://github.com/ynezz/librs232/issues/new).
Do not ever try to contact the author with support requests directly via email. Those emails are
just simply blackholed.

For bugs, features etc. just simply summon a pull request with fix over GitHub also :-)

Quality Assurance
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

I'm using Jenkins for the QA/CI, so this build/testing matrix is actually run
after every commit. 
