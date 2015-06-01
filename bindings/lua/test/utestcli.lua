control_port = arg[1] or CONTROL_PORT or '\\\\.\\CNCB1'
data_port    = arg[2] or DATA_PORT or '\\\\.\\CNCB0'

local rs232     = require "luars232"
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
  local e, p = rs232.open(name)
  if e ~= rs232.RS232_ERR_NOERROR then
    -- handle error
    out:write(string.format("can't open serial port '%s', error: '%s'\n",
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

  out:write(string.format("OK, port open with values '%s'\n", tostring(p)))
  return p
end

local control = open_port(control_port)
local data    = open_port(data_port)
local sep     = '\255'

local function printf(...)
  io.stderr:write(string.format(...))
end

local function remote(...)
  local s = string.format(...)
  s = string.gsub(s, "\n", ";")
  s = string.gsub(s, "%s+", " ")
  s = string.gsub(s, "^%s*", "")
  control:write(s .. sep)
  local e, d = control:read(1, 30000)
  assert(e == rs232.RS232_ERR_NOERROR, rs232.error_tostring(e))
  assert(d == sep)
end

local function reconnect()
  remote[[
    data:in_queue_clear()
    while true do e, d = data:read(1024, 100)
      if e ~= rs232.RS232_ERR_NOERROR then break end
      if not d or #d == 0 then break end
    end
  ]]
  data:in_queue_clear()
  while true do e, d = data:read(1024, 100)
    if e ~= rs232.RS232_ERR_NOERROR then break end
    if not d or #d == 0 then break end
  end
end

local ENABLE = true

local _ENV = TEST_CASE'echo' if ENABLE then
local it = IT(_ENV or _M)

function setup()
  reconnect()
end

local function test_echo(len)
  local s = ('a'):rep(len)

  remote([[
    e, s = data:read(%d, 5000, 1)
    if s then data:write(s) end
  ]], len)

  local e, written = data:write(s)
  assert_equal(rs232.RS232_ERR_NOERROR, e, rs232.error_tostring(e))
  assert_equal(len, written)

  e, s1 = data:read(len, 5000, true)
  assert_equal(rs232.RS232_ERR_NOERROR, e, rs232.error_tostring(e))
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

local _ENV = TEST_CASE'input queue' if ENABLE then
local it = IT(_ENV or _M)

function setup()
  reconnect()
end

local function test_queue_in(len)
  local e, l = data:in_queue()
  assert_equal(rs232.RS232_ERR_NOERROR, e, rs232.error_tostring(e))
  assert_equal(0, l, 'should be emty')

  remote([[
    s = ('a'):rep(%d)
    data:write(s)
  ]], len)

  ztimer.sleep(2000)

  e, l = data:in_queue()
  assert_equal(rs232.RS232_ERR_NOERROR, e, rs232.error_tostring(e))
  assert_equal(len, l)

  local e, d = data:read(1, 0)
  assert_equal(rs232.RS232_ERR_NOERROR, e, rs232.error_tostring(e))
  assert_equal(1, #d)

  e, l = data:in_queue()
  assert_equal(rs232.RS232_ERR_NOERROR, e, rs232.error_tostring(e))
  assert_equal(len-1, l)

  e = data:in_queue_clear()
  assert_equal(rs232.RS232_ERR_NOERROR, e, rs232.error_tostring(e))

  e, l = data:in_queue()
  assert_equal(rs232.RS232_ERR_NOERROR, e, rs232.error_tostring(e))
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

  local e, d = data:read(2*len, tm, true)

  local elapsed = monotonic:stop()

  local alldone = d and (#d == 2 * len)

  if e == rs232.RS232_ERR_TIMEOUT then
    assert_true(is_timed_out(elapsed, tm))
  elseif e == rs232.RS232_ERR_NOERROR then
    assert_string(d)
    if not alldone then
      assert_true(#d < 2*len, fmt("data should be less then %d but got %d", 2*len, #d))
      assert_true(is_timed_out(elapsed, tm))
    end
  else
    if alldone then
      fail(fmt("unexpected error '%s'", rs232.error_tostring(e)))
    else
      fail(rs232.error_tostring(e))
    end
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

local _ENV = TEST_CASE'read some' if ENABLE then
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

  local e, d = data:read(len, tm)

  local elapsed = monotonic:stop()

  local has_data = (d and #d > 0)
  local alldone  = (d and #d == len)

  if e == rs232.RS232_ERR_TIMEOUT then
    if alldone then fail("shuld have passed")
    else assert_true(is_timed_out(elapsed, tm)) end
  elseif e == rs232.RS232_ERR_NOERROR then
    if not has_data then fail("should have timed out")
    elseif not alldone then assert_true(is_timed_out(elapsed, tm)) end
  else
    if alldone then fail(fmt("unexpected error '%s'", rs232.error_tostring(e)))
    else fail(rs232.error_tostring(e)) end
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

local _ENV = TEST_CASE'read all' if ENABLE then
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

  local e, d = data:read(len * 2)

  local elapsed = monotonic:stop()

  assert_equal(rs232.RS232_ERR_NOERROR, e, rs232.error_tostring(e))
  assert_true(d and #d > 0, 'no data')
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

RUN(function()
  remote("os.exit()")
  printf("--------------------------------------------------\n")
  printf("-- testing done in %.2fs\n", started:stop()/1000)
  printf("--------------------------------------------------\n")
end)
