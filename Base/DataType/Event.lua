local function InitEvent(tbl)
    local mt = getmetatable(tbl)
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
                v = v or {}
                local vtpye = type(v)
                assert(vtpye == "function" or vtpye == "table")
                if vtpye == "function" then
                    t.__event__[k].__vec__ = {v}
                    t.__event__[k].__map__ = {[v] = true}
                end
            elseif oldnewindex then
                oldnewindex(t, k, v)
            else
                rawset(t, k, v)
            end
        end
    end
end

local function AddEvent(tbl, e)
    local mt = getmetatable(tbl) or {}
    if not tbl.__event__[e] then
        tbl.__event__[e] = {__vec__ = {}, __map__ = {}}
        setmetatable(
            tbl.__event__[e],
            {
                __index = function(t, k)
                    return function(...)
                        for _, foo in pairs(t.__vec__) do
                            foo(...)
                        end
                    end
                end,
                __newindex = function(t, k, v)
                    if t.__map__[k] then
                        table.remove(t.__vec__, t.__map__[k])
                        t.__map__[k] = nil
                        table.insert(t.__vec__, v)
                        t.__map__[v] = #t.__vec__
                    end
                end,
                __add = function(v1, v2)
                    if v1.__map__[v2] then
                        return v1.__vec__
                    end
                    table.insert(v1.__vec__, v2)
                    v1.__map__[v2] = #v1.__vec__
                    return v1.__vec__
                end,
                __sub = function(v1, v2)
                    for i, v in ipairs(v1.__vec__) do
                        if v == v2 then
                            table.remove(v1.__vec__, i)
                            v1.__map__[v2] = nil
                            break
                        end
                    end
                    return v1.__vec__
                end
            }
        )
    end

    setmetatable(tbl, mt)
end

function Event(tbl, e)
    InitEvent(tbl)
    AddEvent(tbl, e)
    return tbl
end
