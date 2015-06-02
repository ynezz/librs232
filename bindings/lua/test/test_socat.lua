local uv = require "lluv"
local ut = require "lluv.utils"
local zt = require "lzmq.timer"

local server = arg[1] or "testsrv"
local client = arg[1] or "utestcli"

local function spawn(file, args, line_cb)
  local stdout_buffer = ut.Buffer.new()
  local stderr_buffer = ut.Buffer.new()

  local line_mode = "*l"
  if type(line_cb) == 'table' then
    line_mode, line_cb = line_cb[1], line_cb[2]
  end

  local stdout = line_cb and uv.pipe()
  local stderr = line_cb and uv.pipe()

  local function P(pipe, read)
    return {
      stream = pipe,
      flags = uv.CREATE_PIPE + 
              (read and uv.READABLE_PIPE or uv.WRITABLE_PIPE) +
              uv.PROCESS_DETACHED
    }
  end

  local opt = {file = file, args = args or {}}
  if line_cb then
    opt.stdio = {{}, P(stdout, false), P(stderr, false)}
  else
    opt.stdio = {{}, {}, {}}
  end

  local exit_code, run_error
  local proc, pid = uv.spawn(opt, function(handle, err, status, signal)
    if err then
      run_error = err
      print(err)
    end
    exit_code = status
    uv.stop()
  end)

  if line_cb then
    local buffers = {
      [stdout] = stdout_buffer;
      [stderr] = stderr_buffer;
    }

    local function on_data(self, err, data)
      buffer = buffers[self]

      if err then
        local line = buffer:read_all()
        if line then line_cb(line) end
        if err:name() ~= 'EOF' then
          print(err)
          uv.stop()
        end
        return
      end

      buffer:append(data)
      while true do
        local line = buffer:read(line_mode)
        if not line then break end
        if line_cb(line) then uv.stop() end
      end
    end

    stdout:start_read(on_data)
    stderr:start_read(on_data)
  else
    uv.timer():start(5000, function()
      uv.stop()
    end)
  end

  uv.run()
  uv.handles(function(h) h:close() end)
  uv.run()

  if run_error then return nil, run_error end

  return pid, exit_code
end

local function kill(pid)
  uv.kill(pid)
  uv.run()
end

local function socat()
  local port1, port2
  spawn('socat', {'-d', '-d', 'PTY', 'PTY'}, function(line)
    local port = line:match('PTY is%s*([%S]+)')
    if port then
      if not port1 then port1 = port else port2 = port end
    end
    return not not port2
  end)

  return port1, port2
end

local spawn_lua do
  local LUA
  for i = 0, -100, -1 do
    if not arg[i-1] then
      LUA = arg[i]
      break
    end
  end
  spawn_lua = function(...)
    return spawn(LUA, ...)
  end
end

local function run_server(...)
  print("Server:")
  local started
  local pid = spawn_lua({...}, function(line)
    io.write(line) io.flush()
    started = not not line:find('Server started')
    return started
  end)
  print("----------------------------")

  if not started then
    print('Fail start server')
    if pid then kill(pid) end
    os.exit(-1)
  end

  return pid
end

local control_port_1, control_port_2 = assert(socat())
local data_port_1, data_port_2 = assert(socat())

print(control_port_1, "<=>", control_port_2)
print(data_port_1, "<=>", data_port_2)

local pid = run_server("testsrv.lua", control_port_1, data_port_1)

local _, status1 = spawn_lua({"utestcli.lua", control_port_2, data_port_2}, {nil, function(line)
  io.write(line)
end})

kill(pid)

zt.sleep(5000)

local pid = run_server("testsrv.lua", control_port_1, data_port_1)

local _, status2 = spawn_lua({"utestcli_rs232.lua", control_port_2, data_port_2}, {nil, function(line)
  io.write(line)
end})

kill(pid)

if status1 ~= 0 or status2 ~= 0 then
  os.exit(-1)
end
