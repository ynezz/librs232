local port_name = arg[1] or CONTROL_PORT or '\\\\.\\CNCB1'

local rs232 = require("rs232.core")

local ERRORS = {}

for k, v in pairs(rs232) do
	if string.find(k, 'RS232_ERR_') then
		ERRORS[v] = k
	end
end

local function error_name(no)
	return ERRORS[no] or tostring(no)
end

local function errf(no)
	return string.format('error: %s', error_name(no))
end

local function gc()
	for i = 1, 10 do
		collectgarbage('collect')
	end
end

do
local e, p1 = rs232.open(port_name)
assert(e == rs232.RS232_ERR_NOERROR, errf(e))
assert(p1 ~= nil, errf(e))

local e, p2 = rs232.open(port_name)
assert(p2 == nil, errf(e))
assert(e == rs232.RS232_ERR_OPEN, errf(e))
end

gc()

local e, p1 = rs232.open(port_name)
assert(e == rs232.RS232_ERR_NOERROR, errf(e))
assert(p1 ~= nil, errf(e))

p1:close()

local e, p1 = rs232.open(port_name)
assert(e == rs232.RS232_ERR_NOERROR, errf(e))
assert(p1 ~= nil, errf(e))

p1:close()
