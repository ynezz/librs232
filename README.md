#librs232

##Multiplatform library for serial communications over RS-232 (serial port)

[![Build Status](https://travis-ci.org/moteus/librs232.svg?branch=master)](https://travis-ci.org/moteus/librs232)
[![Build status](https://ci.appveyor.com/api/projects/status/1h8c8ptms5yne73d?svg=true)](https://ci.appveyor.com/project/moteus/librs232)

##Lua binding

```Lua
local rs232 = require "rs232"

local p, e = rs232.port('COM1',{
  baud         = '_9600';
  data_bits    = '_8';
  parity       = 'NONE';
  stop_bits    = '_1';
  flow_control = 'OFF';
  rts          = 'ON';
})

p:open()
print(p:write('AT\r\n'))
print(p:read(64, 5000))
p:close()
```
