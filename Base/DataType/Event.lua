local function InitEvent(tbl)
    local mt = getmetatable(tbl) or {}
    if not tbl.__event__ then
        tbl.__event__ = tbl.__event__ or {}
        local oldindex = mt.__index
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

        local oldnewindex = mt.__newindex
        if type(oldnewindex) ~= 'function' then
            oldnewindex = nil
        end

        mt.__index = function(t, k)
            if t.__event__[k] then
                return t.__event__[k]
            elseif oldindex then
                return oldindex(t, k)
            else
                return nil
            end
        end
        mt.__newindex = function(t, k, v)
            if t.__event__[k] then
                if type(v) == 'function' then
                    t.__event__[k]:Clear()
                    t.__event__[k]:Add(v)
                else
                    t.__event__[k] = v
                end
            elseif oldnewindex then
                oldnewindex(t, k, v)
            else
                rawset(t, k, v)
            end
        end
    end
    setmetatable(tbl, mt)
end

local function AddEvent(tbl, e)
    if not tbl.__event__[e] then
        tbl.__event__[e] = {
            __map__ = {},
            Call = function(self, ...)
                local map = rawget(self, '__map__')
                for foo, _ in pairs(map) do
                    foo(...)
                end
            end,
            Clear = function(self)
                local map = rawget(self, '__map__')
                if map then
                    for k, _ in pairs(map) do
                        map[k] = nil
                    end
                end
                return self
            end,
            Add = function(self, v)
                local map = rawget(self, '__map__')
                if map then
                    map[v] = true
                end
                return self
            end,
            Remove = function(self, v)
                local map = rawget(self, '__map__')
                if map then
                    map[v] = nil
                end
                return self
            end
        }
        setmetatable(
            tbl.__event__[e],
            {
                __index = function(t, k)
                    if k ~= '__map__' then
                        local v = rawget(t, k)
                        if v then
                            return v
                        else
                            local map = rawget(t, '__map__')
                            return map[k]
                        end
                    end
                end,
                __newindex = function(t, k, v)
                    local map = rawget(t, '__map__')
                    map[k] = nil
                    map[v] = true
                end,
                __add = function(v1, v2)
                    return v1:Add(v2)
                end,
                __sub = function(v1, v2)
                    return v1:Remove(v2)
                end
            }
        )
    end
end

function Event(tbl, e)
    InitEvent(tbl)
    AddEvent(tbl, e)
    return tbl
end
