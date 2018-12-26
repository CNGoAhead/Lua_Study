local function encrypt(value)
    if type(value) == 'number' and value ~= 0 then
        value = value * 11 + 7
    end
    return value
end

local function decrypt(value)
    if type(value) == 'number' and value ~= 0 then
        value = (value - 7) / 11
    end
    return value
end

local function initPropTable(tbl)
    -- 属性的值存储在这里
    tbl.__props__ = tbl.__props__ or {}

    -- 属性的读写方式存储在这里
    tbl.__propgss__ = tbl.__propgss__ or {}

    if not tbl.PropGet then
        -- 类似rawget
        tbl.PropGet = function(self, name)
            local value
            local key = '_' .. name
            value = decrypt(self.__props__[key])
            return value
        end

        -- 类似rawset
        tbl.PropSet = function(self, name, value)
            local key = '_' .. name
            self.__props__[key] = encrypt(value)
        end

        -- 类似pairs
        tbl.PropPairs = function(self)
            return function(t, key)
                key = next(t, key and '_' .. key)
                local name, value
                if key then
                    name = string.sub(key, 2, -1)
                    local prop = self.__propgss__['prop_' .. name]
                    value = prop.Get and prop:Get(t, key) or nil
                end
                return name, value
            end,
            self.__props__
        end

        -- 
        tbl.IsProp = function(self, name)
            return self.__propgss__['prop_' .. name] ~= nil
        end

        local metatable = getmetatable(tbl) or {}
        local oldindex = metatable.__index
        local oldtable = oldindex
        if type(oldindex) == 'table' then
            oldindex = function(t, key)
                return oldtable[key]
            end
        elseif type(oldindex) == 'function' then
            -- oldindex = oldindex
        else
            oldindex = nil
        end

        metatable.__index = function(t, key)
            local prop = t.__propgss__['prop_' .. key]
            if prop then
                if prop.Get then
                    return prop:Get(t, key)
                else
                    print("can't Get a property without Get function")
                end
            else
                local result = rawget(t, key)
                if result ~= nil then
                    return result
                elseif oldindex then
                    return oldindex(t, key)
                else
                    return nil
                end
            end
        end

        local oldnewindex = metatable.__newindex
        if type(oldnewindex) ~= 'function' then
            oldnewindex = nil
        end

        metatable.__newindex = function(t, key, value)
            local prop = t.__propgss__['prop_' .. key]
            if prop then
                if prop.Set then
                    prop:Set(t, key, value)
                else
                    print("can't Set a property without Set function")
                end
            elseif oldnewindex then
                return oldnewindex(t, key, value)
            else
                rawset(t, key, value)
            end
        end
        setmetatable(tbl, metatable)
    end
end

local function NewProp(p)
    local Prop = {_OnChange = p.OnChange, _OnSet = p.OnSet, _Get = p.Get, _Set = p.Set}
    Prop.Get = p.Get and p.Get or function(self, t, name)
        return t.PropGet(name)
    end
    Prop.Set = function(self, t, name, value)
        if value ~= t[name] then
            if self._Set then
                self._Set(value)
            else
                t.PropSet(name, value)
            end
            if self._OnChange then
                self._OnChange(value)
            end
        end
        if self._OnSet then
            self._OnSet(value)
        end
    end
    return Prop
end

--p = {name = '', default = 0, flag = 'rw', OnSet = function() end, OnChange = function() end, Get = function() end, Set = function() end}
local function Property(tbl, p, ...)
    initPropTable(tbl)
    if p then
        tbl.__props__['_' .. p.name] = encrypt(p.default)
        tbl.__propgss__['prop_' .. p.name] = NewProp(tbl, p)
        if string.find(p.flag, 'r') == nil then
            tbl.__propgss__['prop_' .. p.name].Get = nil
        end
        if string.find(p.flag, 'w') == nil then
            tbl.__propgss__['prop_' .. p.name].Set = nil
        end
        Property(tbl, ...)
    end
end