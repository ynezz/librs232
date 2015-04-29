local rs232 = require "rs232"

local p, e = rs232.port('COM3',{
  baud         = '_9600';
  data_bits    = '_8';
  parity       = 'NONE';
  stop_bits    = '_1';
  flow_control = 'OFF';
  rts          = 'ON';
})

print(p:write('AT\r\n'))
print(p:read(64, 5000))
p:close()
