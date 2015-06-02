package.path = "../?.lua;" .. package.path

local uv    = require "lluv"
local ut    = require "lluv.utils"
local rs232 = require "rs232"

control_port = arg[1] or CONTROL_PORT or 'CNCA1'
data_port    = arg[2] or DATA_PORT or 'CNCA0'

local function split_first(str, sep, plain)
  local e, e2 = string.find(str, sep, nil, plain)
  if e then
    return string.sub(str, 1, e - 1), string.sub(str, e2 + 1)
  end
  return str
end

local function open_port(name)
  local p, e = rs232.port(name)
  local ok, e = p:open()

  if not ok then
    print(string.format("can't open serial port '%s', error: '%s'",
        name, tostring(e)))
    os.exit(-1)
  end

  print(string.format("OK, port open with values '%s'", e))
  return p
end

local function run_test_server(control_port, data_port)
  ztimer    = require "lzmq.timer"
  control   = open_port(control_port)
  data      = open_port(data_port)

  local sep, buffer = '\255'

  print("Server started")
  io.flush()

  while true do
    local d, e = assert(control:read(100, 100))
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

  -- never got here
  control:close()
  data:close()
end

run_test_server(control_port, data_port)

uv.run()