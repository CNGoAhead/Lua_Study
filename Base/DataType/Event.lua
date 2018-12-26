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
                    v = {[v] = true}
                end
                t.__event__[k].__ref__ = v
            elseif oldnewindex then
                oldnewindex(t, k, v)
            else
                rawset(t, k, v)
            end
        end
    end
end

local function EventParams(...)
    return {__params__ = {...}}
end

local function AddEvent(tbl, e)
    local mt = getmetatable(tbl) or {}
    if not tbl.__event__[e] then
        tbl.__event__[e] = {__ref__ = {}}
        setmetatable(
            tbl.__event__[e],
            {
                __index = function(t, k)
                    for foo, _ in pairs(t.__ref__) do
                        if k.__params__ then
                            foo(
                                k.__params__[1],
                                k.__params__[2],
                                k.__params__[3],
                                k.__params__[4],
                                k.__params__[5],
                                k.__params__[6],
                                k.__params__[7],
                                k.__params__[8],
                                k.__params__[9],
                                k.__params__[10],
                                k.__params__[11],
                                k.__params__[12]
                            )
                        else
                            foo(k)
                        end
                    end
                end,
                __newindex = function(t, k, v)
                    if t.__ref__[k] then
                        t.__ref__[k] = nil
                        t.__ref__[v] = true
                    end
                end,
                __add = function(v1, v2)
                    v1.__ref__[v2] = true
                    return v1.__ref__
                end,
                __sub = function(v1, v2)
                    v1.__ref__[v2] = nil
                    return v1.__ref__
                end
            }
        )
    end

    setmetatable(tbl, mt)
end

local function Event(tbl, e)
    InitEvent(tbl)
    AddEvent(tbl, e)
    return tbl
end