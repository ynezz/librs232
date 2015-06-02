control_port = arg[1] or CONTROL_PORT or '\\\\.\\CNCB1'
data_port    = arg[2] or DATA_PORT or '\\\\.\\CNCB0'

rs232  = require "luars232"
out    = io.stderr
ztimer = require "lzmq.timer"

started = ztimer.monotonic():start()

monotonic = ztimer.monotonic()

local function is_timed_out(elapsed, timeout)
  if elapsed >= timeout then return true end
  if (timeout - elapsed) < 100 then return true end
  return false
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

local sep = '\n'

function printf(...)
  io.stderr:write(string.format(...))
end

function pass(...)
  printf(...) 
  io.stderr:write("\n")
end

function fail(...)
  io.stderr:write("ERROR: ")
  printf(...)
  io.stderr:write("!\n")
  os.exit(-1)
end

function warn(...)
  local s = string.format(...)
  io.stderr:write("WARNING: ", s, "\n")
end

function test(test)
  io.stderr:write(
      "----------------------------------------------\n",
      "testing: ", test, "\n",
      "----------------------------------------------\n"
  )
end

function remote(...)
  local s = string.format(...)
  s = string.gsub(s, "\n", ";")
  s = string.gsub(s, "%s+", " ")
  s = string.gsub(s, "^%s*", "")
  control:write(s .. sep)
  local e, d = control:read(1, 30000)
  assert(e == rs232.RS232_ERR_NOERROR, rs232.error_tostring(e))
  assert(d == sep)
end

function reconnect()
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

control = open_port(control_port)
data    = open_port(data_port)

local function test_echo(len)
  reconnect()
  printf("%d bytes: ", len)

  local s = ('a'):rep(len)

  remote([[
    e, s = data:read(%d, 5000, 1)
    if s then data:write(s) end
  ]], len)

  e, written = data:write(s)
  if e ~= rs232.RS232_ERR_NOERROR then fail(rs232.error_tostring(e)) end
  if written ~= len then warn("written to low data %d/%d", len, written) end

  e, s1 = data:read(len, 5000, true)
  if e ~= rs232.RS232_ERR_NOERROR then fail(rs232.error_tostring(e)) end

  if s1 ~= s then fail('Data not matched: %d/%s', len, #s1) end

  pass('ok')
end

local function test_read_timeout_forced(len, tm, sl)
  reconnect()

  printf("%d bytes, %dms total timeout, %dms pause: ", len, tm, sl)

  remote(string.format ([[
      str = string.rep('a', %d)
      data:write(str)
      print('server: sleeping for %dms')
      ztimer.sleep(%d)
      print('server: woke up')
      data:write(str)
  ]], len, sl, sl))

  monotonic:start()

  e, d = data:read(2*len, tm, true)

  elapsed = monotonic:stop()

  alldone = d and (#d == 2 * len)

  if e == rs232.RS232_ERR_TIMEOUT then
    if is_timed_out(elapsed, tm) then
      pass('ok')
    else
      fail("should have timed out")
    end
  elseif e == rs232.RS232_ERR_NOERROR then
    if alldone then
      pass("proper timeout")
    elseif is_timed_out(elapsed, tm) then
      pass("ok")
    else
      fail("should have timed out")
    end
  else
    if alldone then
      fail("unexpected error '%s'", rs232.error_tostring(e))
    else
      fail(rs232.error_tostring(e))
    end
  end
end

local function test_read_some(len, tm, sl)
  reconnect()

  printf("%d bytes, %dms total timeout, %dms pause: ", len, tm, sl)

  remote(string.format ([[
      str = string.rep('a', %d)
      print('server: sleeping for %dms')
      ztimer.sleep(%d)
      print('server: woke up')
      data:write(str)
  ]], len, sl, sl))

  monotonic:start()

  e, d = data:read(len, tm)

  elapsed = monotonic:stop()

  if e == rs232.RS232_ERR_TIMEOUT then
    if is_timed_out(elapsed, tm) or (d and #d > 0) then
      pass('ok')
    else
      fail("should have timed out")
    end
  elseif e == rs232.RS232_ERR_NOERROR then
    if (not d) or (#d == 0) then
      fail("should have timed out")
    elseif d or is_timed_out(elapsed, tm) then
      pass("ok")
    else
      fail("should have timed out 1")
    end
  else
    if alldone then
      fail("unexpected error '%s'", rs232.error_tostring(e))
    else
      fail(rs232.error_tostring(e))
    end
  end

end

local function test_read_all(len, sl)
  reconnect()

  printf("%d bytes, %dms pause: ", len, sl)

  remote(string.format ([[
      str = string.rep('a', %d)
      print('server: sleeping for %dms')
      ztimer.sleep(%d)
      data:write(str)
      print('server: sleeping for %dms')
      ztimer.sleep(%d)
      print('server: woke up')
      data:write(str)
  ]], len, sl, sl, sl, sl))

  monotonic:start()

  e, d = data:read(len * 2)

  elapsed = monotonic:stop()

  if e ~= rs232.RS232_ERR_NOERROR then fail(rs232.error_tostring(e)) end
  if not d or #d == 0  then fail("no data")
  elseif #d > len then warning("wait too long %d, readed %d", elapsed, #d)
  else pass('ok') end

end

local function test_queue_in(len)
  reconnect()
  printf("%d bytes: ", len)

  e, l = data:in_queue()
  if e ~= rs232.RS232_ERR_NOERROR then fail(rs232.error_tostring(e)) end
  if l ~= 0 then fail('should be emty') end

  s = string.rep('a', len)

  remote([[
    s = ('a'):rep(%d)
    data:write(s)
  ]], len)

  ztimer.sleep(2000)

  e, l = data:in_queue()
  if e ~= rs232.RS232_ERR_NOERROR then fail(rs232.error_tostring(e)) end
  if l ~= len then fail('expected %d but got %d', len, l) end

  e = data:in_queue_clear()
  if e ~= rs232.RS232_ERR_NOERROR then fail('clear fail %s', rs232.error_tostring(e)) end

  e, l = data:in_queue()
  if e ~= rs232.RS232_ERR_NOERROR then fail(rs232.error_tostring(e)) end
  if l ~= 0 then warn('clear fail %d', l)
  else pass('ok') end
end


test"echo"
test_echo(128)
test_echo(256)
test_echo(1024)

test"input queue"
test_queue_in(16)
test_queue_in(128)
test_queue_in(256)
test_queue_in(1024)

test"read timeout forced"
test_read_timeout_forced(1024, 2000, 3000)
test_read_timeout_forced(1024, 3000, 2000)
test_read_timeout_forced(2048, 2000, 3000)
test_read_timeout_forced(2048, 3000, 2000)

test"read some"
test_read_some(1024, 2000, 3000)
test_read_some(1024, 3000, 2000)

test"read all"
test_read_all(64, 2000)
test_read_all(128, 2000)
test_read_all(512, 2000)
test_read_all(1024, 2000)

test("shutting server down")
reconnect()
remote("os.exit()")
pass('ok')

test(string.format("done in %.2fs", started:stop()/1000))
