local function split(text, sep)
    text = tostring(text)
    sep = tostring(sep)
    if sep == '' then return {text} end
    local strPos = {0}
    local curPos = 1
    local function AddPos(str)
        local s, e = string.find(text, str, curPos)
        if s and e then
            table.insert(strPos, s - 1)
            table.insert(strPos, e + 1)
            curPos = e + 1
        end
    end
    string.gsub(text, sep, AddPos)
    table.insert(strPos, -1)
    local result = {}
    for k = 1, #strPos, 2 do
        local v = strPos[k]
        if strPos[k + 1] then
            table.insert(result, string.sub(text, v, strPos[k + 1]))
        end
    end
    return result
end

local T

local String = {
    __index = {
        Swap = function(self, obj)
            self.text = tostring(obj)
        end,
    },
    __tostring = function(self)
        return self.text
    end,
    __concat = function(self, append)
        return T(tostring(self) .. tostring(append))
    end,
    __mod = function(self, sub)
        if type(sub) ~= 'table' then
            sub = {sub}
        end
        local text = tostring(self)
        for i, v in ipairs(sub) do
            text = string.gsub(text, '%%' .. i, tostring(v))
        end
        return T(text)
    end,
    __add = function(self, append)
        return self .. append
    end,
    __sub = function(self, subend)
        return T(string.reverse(string.gsub(string.reverse(tostring(self)), string.reverse(subend), '', 1)))
    end,
    __mul = function(self, rept)
        return T(string.rep(tostring(self), rept))
    end,
    __div = function(self, sub)
        return split(tostring(self), sub)
    end,
    __unm = function(self)
        return T(string.reverse(tostring(self)))
    end,
    __eq = function(self, target)
        return tostring(self) == tostring(target)
    end,
    __lt = function(self, target)
        return tostring(self) < tostring(target)
    end,
    __le = function(self, target)
        return not (tostring(self) > tostring(target))
    end,
    __call = function(self, ...)
        local bSuccess, func, ret
        local params = {...}
        func = loadstring(tostring(self))
        assert(func, 'Error In Load String\n', tostring(self))
        bSuccess, ret = xpcall(
            function()
                return func(unpack(params))
            end,
            function( ... )
                print('Error In String\n', tostring(self))
                print(...)
                print(debug.traceback())
            end
        )
        return ret, bSuccess
    end
}

T = function(str)
    str = str or ''
    return setmetatable(
        {text = str},
        String
    )
end

return function()
    _G['T'] = T
    _G['TString'] = T
    return T
end