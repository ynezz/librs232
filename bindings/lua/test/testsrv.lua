control_port = arg[1] or CONTROL_PORT or 'COM4'
data_port    = arg[2] or DATA_PORT or '\\\\.\\CNCA0'

local function split_first(str, sep, plain)
  local e, e2 = string.find(str, sep, nil, plain)
  if e then
    return string.sub(str, 1, e - 1), string.sub(str, e2 + 1)
  end
  return str
end

local function open_port(name)
  local e, p = rs232.open(name)
  if e ~= rs232.RS232_ERR_NOERROR then
    -- handle error
    print(string.format("can't open serial port '%s', error: '%s'",
        name, rs232.error_tostring(e)))
    os.exit(-1)
  end

  -- set port settings
  assert(p:set_baud_rate(rs232.RS232_BAUD_115200) == rs232.RS232_ERR_NOERROR)
  assert(p:set_data_bits(rs232.RS232_DATA_8)      == rs232.RS232_ERR_NOERROR)
  assert(p:set_parity(rs232.RS232_PARITY_NONE)    == rs232.RS232_ERR_NOERROR)
  assert(p:set_stop_bits(rs232.RS232_STOP_1)      == rs232.RS232_ERR_NOERROR)
  assert(p:set_flow_control(rs232.RS232_FLOW_OFF) == rs232.RS232_ERR_NOERROR)
  -- assert(p:set_rts(rs232.RS232_RTS_ON)            == rs232.RS232_ERR_NOERROR)
  print("SET RTS", p:set_rts(rs232.RS232_RTS_ON))

  print(string.format("OK, port open with values '%s'", tostring(p)))
  return p
end

local function run_test_server(control_port, data_port)
  -- this is should be globals
  rs232     = require "luars232"
  ztimer    = require "lzmq.timer"
  control   = open_port(control_port)
  data      = open_port(data_port)

  local sep, buffer = '\255'

  while true do
    local e, d, s = control:read(100, 100)
    if e ~= rs232.RS232_ERR_TIMEOUT then
      assert(e == rs232.RS232_ERR_NOERROR)
      buffer = (buffer or '') .. (d or '')
      local code, tail = split_first(buffer, sep, true)
      if tail then -- we have full code
        print(code)
        control:write(sep)
        buffer = tail
        local fn = (loadstring or load)(code)
        fn()
      end
    end
  end

  -- never got here
  control:close()
  data:close()
end

run_test_server(control_port, data_port)
