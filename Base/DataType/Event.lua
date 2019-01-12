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
        tbl.__event__[e] = {__map__ = {}}
        setmetatable(
            tbl.__event__[e],
            {
                __index = function(t, k)
                    return function(...)
                        for foo, _ in pairs(t.__map__) do
                            foo(...)
                        end
                    end
                end,
                __newindex = function(t, k, v)
                    t.__map__[k] = nil
                    t.__map__[v] = true
                end,
                __add = function(v1, v2)
                    if v1.__map__[v2] then
                        return v1.__map__[v2]
                    end
                    v1.__map__[v2] = true
                    return v1.__map__
                end,
                __sub = function(v1, v2)
                    if v1.__map__[v2] then
                        v1.__map__[v2] = nil
                    end
                    return v1.__map__
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
