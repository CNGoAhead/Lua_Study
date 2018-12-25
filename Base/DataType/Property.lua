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
    tbl.__props = tbl.__props or {}

    -- 属性的读写方式存储在这里
    tbl.__propgss = tbl.__propgss or {}

    if not tbl.PropGet then
        -- 类似rawget
        tbl.PropGet = function(name)
            local value
            local key = '_' .. name
            value = decrypt(tbl.__props[key])
            return value
        end

        -- 类似rawset
        tbl.PropSet = function(name, value)
            local key = '_' .. name
            tbl.__props[key] = encrypt(value)
        end

        -- 类似pairs
        tbl.PropPairs = function()
            return function(t, key)
                key = next(t, key and '_' .. key)
                local name, value
                if key then
                    name = string.sub(key, 2, -1)
                    local prop = tbl.__propgss['prop_' .. name]
                    value = prop.Get and prop.Get() or nil
                end
                return name, value
            end,
            tbl.__props
        end

        -- 
        tbl.IsProp = function(name)
            return tbl.__propgss['prop_' .. name] ~= nil
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
            local prop = rawget(t, '__propgss')['prop_' .. key]
            if prop then
                if prop.Get then
                    return prop.Get()
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
        metatable.__newindex = function(t, key, value)
            local prop = rawget(t, '__propgss')['prop_' .. key]
            if prop then
                if prop.Set then
                    prop.Set(value)
                else
                    print("can't Set a property without Set function")
                end
            -- 修改原表的行为不合适
            -- elseif type(oldnewindex) == 'table' then
            --     return oldnewindex[key]
            -- elseif type(oldnewindex) == 'function' then
            --     return oldnewindex(tab, key, value)
            else
                rawset(t, key, value)
            end
        end
        setmetatable(tbl, metatable)
    end
end

local function NewProp(tbl, p)
    local Prop = {}
    Prop.Get = p.Get and p.Get or Handler(tbl.PropGet, p.name)
    Prop.Set = function(value)
        if value ~= tbl[p.name] then
            if p.Set then
                p.Set(value)
            else
                tbl.PropSet(p.name, value)
            end
            if p.OnChange then
                p.OnChange(value)
            end
        end
        if p.OnSet then
            p.OnSet(value)
        end
    end
    return Prop
end

--p = {name = '', default = 0, flag = 'rw', OnSet = function() end, OnChange = function() end, Get = function() end, Set = function() end}
local function Property(tbl, p, ...)
    initPropTable(tbl)
    if p then
        tbl.__props['_' .. p.name] = encrypt(p.default)
        tbl.__propgss['prop_' .. p.name] = NewProp(tbl, p)
        if string.find(p.flag, 'r') == nil then
            tbl.__propgss['prop_' .. p.name].Get = nil
        end
        if string.find(p.flag, 'w') == nil then
            tbl.__propgss['prop_' .. p.name].Set = nil
        end
        Property(tbl, ...)
    end
end