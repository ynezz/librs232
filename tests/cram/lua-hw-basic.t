TODO: failed tests on OSX Lion: baudrate 460800 and flow control XON/XOFF giving 5 (ERR_CONFIG) error

  $ lua -lluars232 -e "
  > local name = os.getenv('LUA_RS232_PORT_NAME')
  > local e,p = luars232.open(name)
  > print(p)
  > print(luars232.open('duh'))
  > print(p:read(1, 1))
  > print(p:operation_duration())
  > print(p:write('west'))
  > print(p:close())
  > print(p:close())
  > e,p = luars232.open(name)
  > print(p:set_baud_rate(luars232.RS232_BAUD_9600))
  > print(p:set_data_bits(luars232.RS232_DATA_7))
  > print(p:set_parity(luars232.RS232_PARITY_EVEN))
  > print(p)
  > print(p:set_baud_rate(luars232.RS232_BAUD_38400))
  > print(luars232.error_tostring(p:set_stop_bits(luars232.RS232_STOP_2)))
  > print(p)
  > print(p:close())
  > print(luars232.error_tostring(p:close()))
  > "
  device: .*, baud: 115200, data bits: 8, parity: none, stop bits: 1, flow control: off (re)
  2\tnil (esc)
  9\tnil\t0 (esc)
  \d.\d+ (re)
  0\t4 (esc)
  0
  11
  0
  0
  0
  device: .*, baud: 9600, data bits: 7, parity: even, stop bits: 1, flow control: off (re)
  0
  no error
  device: .*, baud: 38400, data bits: 7, parity: even, stop bits: 2, flow control: off (re)
  0
  port closed error
