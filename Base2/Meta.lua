local Meta = {}

local function SpawnGetter(obj, meta, getter)
    meta = meta or {}
    if type(getter) == 'function' then
        meta.__tindex = meta.__tindex or {}
        meta.__findex = getter
        meta.__index = function(_, k)
            local v = getter(obj, k)
            if v ~= nil then
                return v
            end
            return meta.__tindex[k]
        end
    elseif type(getter) == 'table' then
        meta.__index = getter
    end
    return meta
end

function Meta.PushBackGetter(obj, getter)
    if not getter then
        return
    end
    local meta = getmetatable(obj) or {}
    if meta.__index then
        Meta.PushBackGetter(meta.__tindex or meta.__index, getter)
    else
        setmetatable(obj, SpawnGetter(obj, meta, getter))
    end
    return obj
end

function Meta.PushFrontGetter(obj, getter)
    if not getter then
        return
    end
    local meta = getmetatable(obj) or {}
    local oindex = meta.__index
    if oindex then
        local ofindex = meta.__findex
        local otindex = meta.__tindex
        meta.__tindex = nil
        meta.__findex = nil
        meta.__index = nil
        local nmeta = SpawnGetter(obj, meta, getter)
        setmetatable(nmeta.__tindex or nmeta.__index, SpawnGetter(obj, {__tindex = otindex}, ofindex or oindex))
        return setmetatable(obj, nmeta)
    else
        return setmetatable(obj, SpawnGetter(obj, meta, getter))
    end
end

local function SpawnSetter(obj, meta, setter)
    meta = meta or {}
    if type(setter) == 'function' then
        meta.__tnewindex = meta.__tnewindex or {}
        meta.__fnewindex = setter
        meta.__newindex = function(_, k, v)
            local m = getmetatable(meta.__tnewindex)
            if m and m.__newindex then
                if not m.__fnewindex then
                    m.__newindex[k] = v
                    return setter(obj, k, v)
                elseif m.__newindex(obj, k, v) then
                    return setter(obj, k, v)
                end
            else
                return setter(obj, k, v)
            end
        end
    elseif type(setter) == 'table' then
        meta.__newindex = setter
    end
    return meta
end

function Meta.PushBackSetter(obj, setter)
    if not setter then
        return
    end
    local meta = getmetatable(obj) or {}
    if meta.__newindex then
        local type = type(meta.__newindex)
        if type == 'function' then
            Meta.PushBackSetter(meta.__tnewindex, setter)
        elseif type == 'table' then
            Meta.PushBackSetter(meta.__newindex, setter)
        end
    else
        setmetatable(obj, SpawnSetter(obj, meta, setter))
    end
    return obj
end

function Meta.PushFrontSetter(obj, setter)
    if not setter then
        return
    end
    local meta = getmetatable(obj) or {}
    local onewindex = meta.__newindex
    if onewindex then
        local ofnewindex = meta.__fnewindex
        local otnewindex = meta.__tnewindex
        meta.__tnewindex = nil
        meta.__fnewindex = nil
        meta.__newindex = nil
        local nmeta = SpawnSetter(obj, meta, setter)
        setmetatable(nmeta.__tnewindex or nmeta.__newindex, SpawnSetter(obj, {__tnewindex = otnewindex}, ofnewindex or onewindex))
        return setmetatable(obj, nmeta)
    else
        return setmetatable(obj, SpawnSetter(obj, meta, setter))
    end
end

function Meta.PopBackGetter(obj)
    local meta = getmetatable(obj)
    local llast, last
    while meta and meta.__index do
        llast = last
        last = meta
        meta = getmetatable(meta.__tindex or meta.__index)
    end
    if last then
        last.__tindex = nil
        last.__index = nil
        if not next(last) and llast then
            setmetatable(llast, nil)
        end
    end
    return obj
end

function Meta.PopFrontGetter(obj)
    local meta = getmetatable(obj) or {}
    local index = meta.__tindex or meta.__index
    local nmeta = index and getmetatable(index)
    meta.__tindex = nmeta and nmeta.__tindex
    meta.__index = nmeta and nmeta.__index
    if not next(meta) then
        setmetatable(obj, nil)
    end
    return obj
end

function Meta.PopBackSetter(obj)
    local meta = getmetatable(obj)
    local llast, last
    while meta and meta.__newindex do
        llast = last
        last = meta
        meta = getmetatable(meta.__tnewindex or meta.__newindex)
    end
    if last then
        last.__tnewindex = nil
        last.__newindex = nil
        last.__fnewindex = nil
        if not next(last) and llast then
            setmetatable(llast, nil)
        end
    end
    return obj
end

function Meta.PopFrontSetter(obj)
    local meta = getmetatable(obj) or {}
    local newindex = meta.__tnewindex or meta.__newindex
    local nmeta = newindex and getmetatable(newindex)
    meta.__tnewindex = nmeta and nmeta.__tnewindex
    meta.__fnewindex = nmeta and nmeta.__fnewindex
    meta.__newindex = nmeta and nmeta.__newindex
    if not next(meta) then
        setmetatable(obj, nil)
    end
    return obj
end

return function()
    return Meta
end