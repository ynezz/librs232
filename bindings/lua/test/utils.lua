local lunit = lunit
local RUN   = lunit and function() end or function (on_exit)
  local res = lunit.run()
  if on_exit then on_exit() end
  if res.errors + res.failed > 0 then
    os.exit(-1)
  end
  return os.exit(0)
end
lunit       = require "lunit"

local IT    = function(m)
  return setmetatable(m, {__call = function(self, describe, fn)
    self["test " .. describe] = fn
  end})
end

local function nreturn(...)
  return select("#", ...), ...
end

local function PASS() return true end

local function FALSE() return false end

local function CMD(t)if type(t)=="table"then return table.concat(t)end return t end

local is_equal do
  local cmp_t
  local function cmp_v(v1,v2)
    local flag = true
    if type(v1) == 'table' then
      flag = (type(v2) == 'table') and cmp_t(v1, v2)
    else
      flag = (v1 == v2)
    end
    return flag
  end

  function cmp_t(t1,t2)
    for k in pairs(t2)do
      if t1[k] == nil then
        return false
      end
    end
    for k,v in pairs(t1)do
      if not cmp_v(t2[k],v) then 
        return false 
      end
    end
    return true
  end

  is_equal = cmp_v
end

return {
  IT       = IT;
  CMD      = CMD;
  RUN      = RUN;
  PASS     = PASS;
  FALSE    = FALSE;
  nreturn  = nreturn;
  is_equal = is_equal;
}
