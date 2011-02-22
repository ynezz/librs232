port_name = "/dev/ttyS0"
platform = "linux"

-- port_name = "COM1"
-- platform = "win32"


rs232 = require("luars232")


function time_stamp()
	t = os.date("*t")
	return string.format("[%02s.%02s.%s %02s:%02s:%02s] ",
			     t.day, t.month, t.year,
			     t.hour, t.min, t.sec)
end

oldprint = print
function myprint(text)
	text = time_stamp() .. text
	oldprint(text)
	file = io.open("test_lua_log.txt", "a+")
	file:write(text .. "\n")
	file:close()
end
print = myprint

function string.lines(str)
	return string.gfind(str, "([^\n]*)\n")
end

function format_test(text, err)
	local ret = "\n"
	local line_number = 1
	local _, _, line_err, line_str = string.find(err, ".*:(%d+):(.*)")
	for line in string.lines(text) do
		if line_number == tonumber(line_err) then
			ret = ret .. string.format("-->   %d. %s (%s)\n", line_number, line, line_str)
		else
			ret = ret .. string.format("% 8d. %s\n", line_number, line)
		end
		line_number = line_number + 1
	end

	return ret
end

function test(text)
	local chunk, err = loadstring(text)
	if chunk == nil then
		print(string.format([[
--------------------------------------------------------------- 
%s
loadstring error: '%s'
--------------------------------------------------------------- 
]], format_test(text, err), err))
		return false
	end

	local ret, msg = pcall(chunk)
	if ret == false then
		print(string.format([[
--------------------------------------------------------------- 
%s
pcall error: '%s'
--------------------------------------------------------------- 
]], format_test(text, msg), msg))
		return false
	end

	return true
end

baud_rates = {
	"rs232.RS232_BAUD_9600",
	"rs232.RS232_BAUD_19200",
	"rs232.RS232_BAUD_38400",
	"rs232.RS232_BAUD_57600",
	"rs232.RS232_BAUD_115200",
}

-- It's such a crap, Windows seems to not like 5 data
-- bits. If you make this test to work with 5 data bits on
-- Windows, I'll buy you a beer or two...
if platform == "win32" then
	data_bits = {
		"rs232.RS232_DATA_6",
		"rs232.RS232_DATA_7",
		"rs232.RS232_DATA_8",
	}
else
	data_bits = {
		"rs232.RS232_DATA_5",
		"rs232.RS232_DATA_6",
		"rs232.RS232_DATA_7",
		"rs232.RS232_DATA_8",
	}
end

stop_bits = {
	"rs232.RS232_STOP_1",
	"rs232.RS232_STOP_2",
}

parity_bits = {
	"rs232.RS232_PARITY_NONE",
	"rs232.RS232_PARITY_ODD",
	"rs232.RS232_PARITY_EVEN",
}

flow_bits = {
	"rs232.RS232_FLOW_OFF",
	"rs232.RS232_FLOW_HW",
	"rs232.RS232_FLOW_XON_XOFF",
}

dtr_bits = {
	"rs232.RS232_DTR_ON",
	"rs232.RS232_DTR_OFF",
}

rts_bits = {
	"rs232.RS232_RTS_ON",
	"rs232.RS232_RTS_OFF",
}

errors = {
	"rs232.RS232_ERR_NOERROR",
	"rs232.RS232_ERR_UNKNOWN",
	"rs232.RS232_ERR_OPEN",
	"rs232.RS232_ERR_CLOSE",
	"rs232.RS232_ERR_FLUSH",
	"rs232.RS232_ERR_CONFIG",
	"rs232.RS232_ERR_READ",
	"rs232.RS232_ERR_WRITE",
	"rs232.RS232_ERR_SELECT",
	"rs232.RS232_ERR_TIMEOUT",
	"rs232.RS232_ERR_IOCTL",
	"rs232.RS232_ERR_PORT_CLOSED",
}

assert(
	test(string.format([[
		local e, p = rs232.open("%s")
		assert(e == rs232.RS232_ERR_NOERROR)
		assert(p ~= nil)
		assert(p:close() == rs232.RS232_ERR_NOERROR)
	]], port_name))
)

assert(
	test([[
		local e, p = rs232.open("/dev/hell")
		assert(e == rs232.RS232_ERR_OPEN)
		assert(p == nil)
	]])
)

for _, baud in pairs(baud_rates) do
for _, data in pairs(data_bits) do
for _, parity in pairs(parity_bits) do
for _, stop in pairs(stop_bits) do
for _, flow in pairs(flow_bits) do
for _, dtr in pairs(dtr_bits) do
for _, rts in pairs(rts_bits) do
	assert(
		test(
			string.format([[
				local e, p = rs232.open("%s")
				assert(e == rs232.RS232_ERR_NOERROR)
				assert(p ~= nil)

				local bret = rs232.error_tostring(p:set_baud_rate(%s))
				local dret = rs232.error_tostring(p:set_data_bits(%s))
				local pret = rs232.error_tostring(p:set_parity(%s))
				local sret = rs232.error_tostring(p:set_stop_bits(%s))
				local fret = rs232.error_tostring(p:set_flow_control(%s))
				local dtr_ret = rs232.error_tostring(p:set_dtr(%s))
				local rts_ret = rs232.error_tostring(p:set_rts(%s))
				 
				local text = tostring(p)
				assert(text ~= nil)
				 
				local errors = ""
				if bret ~= "no error" then
					errors = "set baud rate,"
				end
				if dret ~= "no error" then
					errors = errors .. "set data bits,"
				end
				if pret ~= "no error" then
					errors = errors .. "set parity,"
				end
				if sret ~= "no error" then
					errors = errors .. "set stop bits,"
				end
				if fret ~= "no error" then
					errors = errors .. "set flow control"
				end
				if dtr_ret ~= "no error" then
					errors = errors .. "set dtr"
				end
				if rts_ret ~= "no error" then
					errors = errors .. "set rts"
				end
				 
				if (string.len(errors) > 0) then
					print(string.format(" [!] ERROR: %%s (failed: %%s)", text, errors))
				else
					print(string.format(" [!] OK: %%s", text))
				end
				 
				assert(p:close() == rs232.RS232_ERR_NOERROR)
				]], port_name, baud, data, parity, stop, flow, dtr, rts)
		)
	)
end
end
end
end
end
end
end

for _, baud in pairs(baud_rates) do
for _, data in pairs(data_bits) do
for _, parity in pairs(parity_bits) do
for _, stop in pairs(stop_bits) do
for _, flow in pairs(flow_bits) do
for _, dtr in pairs(dtr_bits) do
for _, rts in pairs(rts_bits) do
	assert(
		test(
			string.format([[
				local e, p = rs232.open("%s")
				assert(e == rs232.RS232_ERR_NOERROR)
				assert(p ~= nil)
				 
				assert(p:set_baud_rate(%s) == rs232.RS232_ERR_NOERROR)
				assert(p:set_data_bits(%s) == rs232.RS232_ERR_NOERROR)
				assert(p:set_parity(%s) == rs232.RS232_ERR_NOERROR)
				assert(p:set_stop_bits(%s) == rs232.RS232_ERR_NOERROR)
				assert(p:set_flow_control(%s) == rs232.RS232_ERR_NOERROR)
				assert(p:set_dtr(%s) == rs232.RS232_ERR_NOERROR)
				assert(p:set_rts(%s) == rs232.RS232_ERR_NOERROR)
				 
				local baud = p:baud_rate()
				local str_baud1 = p:baud_rate_tostring()
				local str_baud2 = p:baud_rate_tostring(baud)
				assert(str_baud1 == str_baud2)
				 
				local bits = p:data_bits()
				local str_bits1 = p:data_bits_tostring()
				local str_bits2 = p:data_bits_tostring(bits)
				assert(str_bits1 == str_bits2)
				 
				local parity = p:parity()
				local str_parity1 = p:parity_tostring()
				local str_parity2 = p:parity_tostring(parity)
				assert(str_parity1 == str_parity2)
				 
				local stop = p:stop_bits()
				local str_stop1 = p:stop_bits_tostring()
				local str_stop2 = p:stop_bits_tostring(stop)
				assert(str_stop1 == str_stop2)
				 
				local flow = p:flow_control()
				local str_flow1 = p:flow_control_tostring()
				local str_flow2 = p:flow_control_tostring(flow)
				assert(str_flow1 == str_flow2)

				local dtr = p:dtr()
				local str_dtr1 = p:dtr_tostring()
				local str_dtr2 = p:dtr_tostring(dtr)
				assert(str_dtr1 == str_dtr2)

				local rts = p:rts()
				local str_rts1 = p:rts_tostring()
				local str_rts2 = p:rts_tostring(rts)
				assert(str_rts1 == str_rts2)
				 
				local e = p:flush()
				assert(e == rs232.RS232_ERR_NOERROR)
				 
				e, d, l = p:read(1, 100)
				assert(e == rs232.RS232_ERR_NOERROR)
				assert(d == nil)
				assert(l == 0)
				 
				-- not implemented yet...
				if platform ~= "win32" then
					local forced = 1
					e, d, l = p:read(1, 100, forced)
					assert(e == rs232.RS232_ERR_NOERROR)
					assert(d == nil)
					assert(l == 0)
				end
				 
				local forced = 0
				e, d, l = p:read(1, 100, forced)
				assert(e == rs232.RS232_ERR_NOERROR)
				assert(d == nil)
				assert(l == 0)
				 
				e, l = p:write("ynezz")
				assert(e == rs232.RS232_ERR_NOERROR)
				 
				-- althought the write is successful it returns 0 bytes written
				-- in some baud/data/stop/flow combinations...
				 
				if platform ~= "win32" then
					assert(l == 5)
				end
				 
				e, l = p:write("ynezz", 100)
				assert(e == rs232.RS232_ERR_NOERROR)
				 
				-- althought the write is successful it returns 0 bytes written
				-- in some baud/data/stop/flow combinations...
				 
				if platform ~= "win32" then
					assert(l == 5)
				end
				 
				local text = tostring(p)
				assert(text ~= nil)
				print("tostring(p): " .. text)
				 
				assert(p:close() == rs232.RS232_ERR_NOERROR)
				]], port_name, baud, data, parity, stop, flow, dtr, rts)
		)
	)
end
end
end
end
end
end
end

print("[*] All tests passed succesfuly!")
