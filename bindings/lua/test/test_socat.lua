local uv = require "lluv"
local ut = require "lluv.utils"

local function spawn(file, args, line_cb)
  local stdout_buffer = ut.Buffer.new()
  local stderr_buffer = ut.Buffer.new()

  local stdout = uv.pipe()
  local stderr = uv.pipe()

  local function P(pipe, read)
    return {
      stream = pipe,
      flags = uv.CREATE_PIPE + 
              (read and uv.READABLE_PIPE or uv.WRITABLE_PIPE) +
              uv.PROCESS_DETACHED
    }
  end

  uv.spawn({file = file, args = args or {},
    stdio = {{}, P(stdout, false), P(stderr, false)}
  }, function(handle, err, status, signal)
    if err then print(err) end
    uv.stop()
  end)

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
    if not err then stderr_buffer:append(data) end
  end)

  uv.run()
  uv.handles(function(h) h:close() end)
  uv.run()
end

local function socat()
  local port1, port2

  spawn('socat', {'-d', '-d', 'PTY', 'PTY'}, function(line)
    print(">>", line)
    local port = line:match('PTY is%s*([%S]+)')
    if port then
      if not port1 then port1 = port else port2 = port end
    end
    return not not port2
  end)

  return port1, port2
end

print('SOCAT #1', socat())
print('SOCAT #2', socat())
