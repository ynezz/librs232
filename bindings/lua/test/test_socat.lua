local uv = require "lluv"
local ut = require "lluv.utils"

local function spawn(file, args, line_cb)
  local stdout_buffer = ut.Buffer.new()
  local stderr_buffer = ut.Buffer.new()

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

  uv.spawn(opt, function(handle, err, status, signal)
    if err then print(err) end
    uv.stop()
  end)

  if line_cb then
    stdout:start_read(function(self, err, data)
      if err then
        print(err)
        return uv.stop()
      end

      stdout_buffer:append(data)
      while true do
        local line = stdout_buffer:read_line()
        if not line then break end
        if line_cb(line) then uv.stop() end
      end
    end)

    stderr:start_read(function(self, err, data)
      if err then
        print(err)
        return uv.stop()
      end

      stderr_buffer:append(data)
      while true do
        local line = stderr_buffer:read_line()
        if not line then break end
        if line_cb(line) then uv.stop() end
      end
    end)
  else
    uv.timer():start(5000, function()
      uv.stop()
    end)
  end

  uv.run()
  uv.handles(function(h) h:close() end)
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

local control_port_1, control_port_2 = assert(socat())
local data_port_1, data_port_2 = assert(socat())

print(control_port_1, "<=>", control_port_2)
print(data_port_1, "<=>", data_port_2)

spawn_lua{"testsrv.lua", control_port_1, data_port_1}

CONTROL_PORT = control_port_2
DATA_PORT    = data_port_2

require "testcli"
