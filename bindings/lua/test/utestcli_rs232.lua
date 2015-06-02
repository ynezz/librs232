package.path = "../?.lua;" .. package.path

local control_port = arg[1] or CONTROL_PORT or 'CNCB1'
local data_port    = arg[2] or DATA_PORT or 'CNCB0'

local rs232     = require "rs232"
local ztimer    = require "lzmq.timer"
local utils     = require "utils"
local TEST_CASE = require "lunit".TEST_CASE

local out       = io.stderr
local started   = ztimer.monotonic():start()
local monotonic = ztimer.monotonic()

local pcall, error, type, table, ipairs, print = pcall, error, type, table, ipairs, print
local RUN = utils.RUN
local IT, CMD, PASS = utils.IT, utils.CMD, utils.PASS
local nreturn, is_equal = utils.nreturn, utils.is_equal
local fmt = string.format

local function is_timed_out(elapsed, timeout)
  if elapsed >= timeout then return true end
  if (timeout - elapsed) < 100 then return true end
  return false, string.format("timeout expected (%d - %d) but got %d", timeout - 100, timeout, elapsed)
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

local control, data
local sep     = '\255'

local function printf(...)
  io.stderr:write(string.format(...))
end

local function remote(...)
  local s = string.format(...)
  s = string.gsub(s, "\n", ";")
  s = string.gsub(s, "%s+", " ")
  s = string.gsub(s, "^%s*", "")
  s = s .. sep
  assert(#s == control:write(s))
  local d, e = control:read(1, 5000)
  assert(d, tostring(e))
  assert(not e, tostring(e))
  assert(#d == 1)
  assert(d == sep, "Got " .. string.byte(d))
end

local function reconnect()
  remote[[
    data:in_queue_clear()
    while true do d = data:read(1024, 100)
      if not d or #d == 0 then break end
    end
  ]]
  data:in_queue_clear()
  while true do d = data:read(1024, 100)
    if not d or #d == 0 then break end
  end
end

local ENABLE = true

local _ENV = TEST_CASE'echo'                if ENABLE or true then
local it = IT(_ENV or _M)

function setup()
  reconnect()
end

local function test_echo(len)
  local s = ('a'):rep(len)

  remote([[
    s = data:read(%d, 5000, 1)
    if s then data:write(s) end
  ]], len)

  local ret = assert(data:write(s))
  if type(ret) == 'number' then
    assert_equal(len, ret)
  else
    assert_equal(data, ret)
  end

  local s1 = assert_string(data:read(len, 5000, true))
  assert_equal(len, #s1)
end

local function test(len)
  it(fmt("%d bytes", len), function()
    test_echo(len)
  end)
end

test(128)
test(256)
test(1024)

end

local _ENV = TEST_CASE'read timeout forced' if ENABLE then
local it = IT(_ENV or _M)

function setup()
  reconnect()
end

local function test_read_timeout_forced(len, tm, sl)
  remote([[
      str = string.rep('a', %d)
      data:write(str)
      print('server: sleeping for %dms')
      ztimer.sleep(%d)
      print('server: woke up')
      data:write(str)
  ]], len, sl, sl)

  monotonic:start()

  local d, e = assert_string(data:read(2*len, tm, true))

  local elapsed = monotonic:stop()

  assert(#d > 0)

  if #d ~= 2 * len then
    assert_true(is_timed_out(elapsed, tm))
  end
end

local function test(len, tm, sl)
  it(fmt("%d bytes, %dms total timeout, %dms pause", len, tm, sl), function()
    test_read_timeout_forced(len, tm, sl)
  end)
end

test(1024, 2000, 3000)
test(1024, 3000, 2000)
test(2048, 2000, 3000)
test(2048, 3000, 2000)

end

local _ENV = TEST_CASE'read some'           if ENABLE then
local it = IT(_ENV or _M)

function setup()
  reconnect()
end

local function test_read_some(len, tm, sl)
  remote([[
      str = string.rep('a', %d)
      print('server: sleeping for %dms')
      ztimer.sleep(%d)
      print('server: woke up')
      data:write(str)
  ]], len, sl, sl)

  monotonic:start()

  local d = assert_string(data:read(len, tm))

  local elapsed = monotonic:stop()

  if #d < len then
    assert_true(is_timed_out(elapsed, tm))
  end
end

local function test(len, tm, sl)
  it(fmt("%d bytes, %dms total timeout, %dms pause", len, tm, sl), function()
    test_read_some(len, tm, sl)
  end)
end

test(1024, 2000, 3000)
test(1024, 3000, 2000)

end

local _ENV = TEST_CASE'read all'            if ENABLE then
local it = IT(_ENV or _M)

function setup()
  reconnect()
end

local function test_read_all(len, sl)
  remote([[
      str = string.rep('a', %d)
      print('server: sleeping for %dms')
      ztimer.sleep(%d)
      data:write(str)
      print('server: sleeping for %dms')
      ztimer.sleep(%d)
      print('server: woke up')
      data:write(str)
  ]], len, sl, sl, sl, sl)

  monotonic:start()

  local d = assert_string(data:read(len * 2))

  local elapsed = monotonic:stop()

  assert_true(#d > 0, 'no data')
  assert_true(#d <= len, fmt("wait too long %d, readed %d", elapsed, #d))
end

local function test(len, sl)
  it(fmt("%d bytes, %dms pause", len, sl), function()
    test_read_all(len, sl)
  end)
end

test(64,   2000)
test(128,  2000)
test(512,  2000)
test(1024, 2000)

end

local _ENV = TEST_CASE'input queue'         if ENABLE then
local it = IT(_ENV or _M)

function setup()
  reconnect()
end

local function test_queue_in(len)
  local l = assert_number(data:in_queue())
  assert_equal(0, l, 'should be emty')

  remote([[
    s = ('a'):rep(%d)
    data:write(s)
  ]], len)

  ztimer.sleep(2000)

  l = assert_number(data:in_queue())
  assert_equal(len, l)

  local d = assert_string(data:read(1, 0))
  assert_equal(1, #d)

  l = assert_number(data:in_queue())
  assert_equal(len-1, l)

  assert(data:in_queue_clear())

  l = assert_number(data:in_queue())
  assert_equal(0, l, 'should be emty')
end

local function test(len)
  it(fmt("%d bytes", len), function()
    test_queue_in(len)
  end)
end

test(16)
test(128)
test(256)
test(1024)

end

control = open_port(control_port)
data    = open_port(data_port)

RUN(function()
  remote("ztimer.sleep(500);os.exit()")
  printf("--------------------------------------------------\n")
  printf("-- testing done in %.2fs\n", started:stop()/1000)
  printf("--------------------------------------------------\n")
end)

