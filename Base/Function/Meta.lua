local Meta = {}

-- function Meta.PushBack(obj, meta)
--     local ometa = getmetatable(obj)
--     if ometa then
--         Meta.PushBack(ometa, meta)
--     else
--         setmetatable(obj, meta)
--     end
--     return obj
-- end

-- function Meta.PushFront(obj, meta)
--     return setmetatable(obj, setmetatable(meta, getmetatable(obj)))
-- end

-- function Meta.PopBack(obj)
--     local o = obj
--     local last
--     while getmetatable(o) do
--         last = o
--         o = getmetatable(o)
--     end
--     if last then
--         setmetatable(last, nil)
--     end
--     return obj
-- end

-- function Meta.PopFront(obj)
--     local meta = getmetatable(obj)
--     if meta then
--         setmetatable(obj, getmetatable(meta))
--         setmetatable(meta, nil)
--     end
--     return obj
-- end

-- function Meta.PushBackGetter(obj, getter)
--     local meta = getmetatable(obj) or {}
--     if meta.__index then
--         Meta.PushBackGetter(meta, getter)
--     else
--         meta.__index = getter
--         setmetatable(obj, meta)
--     end
--     return obj
-- end

-- function Meta.PushBackSetter(obj, setter)
--     local meta = getmetatable(obj) or {}
--     if meta.__newindex then
--         Meta.PushBackGetter(meta, getter)
--     else
--         meta.__newindex = getter
--         setmetatable(obj, meta)
--     end
--     return obj
-- end

-- function Meta.PushFrontGetter(obj, getter)
--     local meta = getmetatable(obj) or {}
--     if meta.__index then
--         return setmetatable(obj, setmetatable({__index = getter}, getmetatable(obj)))
--     else
--         meta.__index = getter
--         return setmetatable(obj, meta)
--     end
-- end

-- function Meta.PushFrontSetter(obj, setter)
--     local meta = getmetatable(obj) or {}
--     if meta.__newindex then
--         return setmetatable(obj, setmetatable({__index = setter}, getmetatable(obj)))
--     else
--         meta.__newindex = setter
--         return setmetatable(obj, meta)
--     end
-- end

-- function Meta.PopBackGetter(obj)
--     local meta = getmetatable(obj) or {}
--     if meta.__index then
--         Meta.PopBackGetter(meta)
--     else
--         meta.__index = nil
--         setmetatable(obj, next(meta) and meta or nil)
--     end
--     return obj
-- end

-- function Meta.PopBackSetter(obj, setter)
--     local meta = getmetatable(obj) or {}
--     if meta.__newindex then
--         Meta.PopBackSetter(meta)
--     else
--         meta.__newindex = nil
--         setmetatable(obj, next(meta) and meta or nil)
--     end
--     return obj
-- end

-- local function _RemoveMeta(obj)
--     local meta = getmetatable(obj)
--     if not meta or next(meta) then
--         return obj
--     else
--         return setmetatable(obj, getmetatable(meta))
--     end
-- end

-- function Meta.PopFrontGetter(obj)
--     local meta = getmetatable(obj) or {}
--     meta.__index = nil
--     return _RemoveMeta(obj)
-- end

-- function Meta.PopFrontSetter(obj)
--     local meta = getmetatable(obj) or {}
--     meta.__newindex = nil
--     return _RemoveMeta(obj)
-- end

-- function Meta.RemoveGetter(obj, getter)
--     local meta = getmetatable(obj)
--     if meta.__index == getter then
--         meta.__index = nil
--         _RemoveMeta(obj)
--     elseif meta then
--         Meta.RemoveGetter(meta, getter)
--     end
--     return obj
-- end

-- function Meta.RemoveSetter(obj, setter)
--     local meta = getmetatable(obj)
--     if meta.__newindex == getter then
--         meta.__newindex = nil
--         _RemoveMeta(obj)
--     elseif meta then
--         Meta.RemoveGetter(meta, getter)
--     end
--     return obj
-- end

local function SpawnGetter(meta, getter)
    meta = meta or {}
    if type(getter) == 'function' then
        meta.__tindex = {}
        meta.__findex = getter
        meta.__index = function(_, k)
            local v = getter(_, k)
            if v ~= nil then
                return v
            else
                return meta.__tindex[k]
            end
        end
    elseif type(getter) == 'table' then
        meta.__index = getter
    end
    return meta
end

function Meta.PushBackGetter(obj, getter)
    local meta = getmetatable(obj) or {}
    if meta.__index then
        local type = type(meta.__index)
        if type == 'function' then
            Meta.PushBackGetter(meta.__tindex, getter)
        elseif type == 'table' then
            Meta.PushBackGetter(meta.__index, getter)
        end
    else
        setmetatable(obj, SpawnGetter(meta, getter))
    end
    return obj
end

function Meta.PushFrontGetter(obj, getter)
    local meta = getmetatable(obj) or {}
    local oindex = meta.__index
    if oindex then
        local ofindex = meta.__findex
        local otindex = meta.__tindex
        meta.__tindex = nil
        meta.__findex = nil
        meta.__index = nil
        local nmeta = SpawnGetter(meta, getter)
        setmetatable(nmeta.__tindex or nmeta.__index, SpawnGetter({__tindex = otindex}, ofindex or oindex))
        return setmetatable(obj, nmeta)
    else
        return setmetatable(obj, SpawnGetter(meta, getter))
    end
end

local function SpawnSetter(meta, setter)
    meta = meta or {}
    if type(setter) == 'function' then
        meta.__tnewindex = meta.__tnewindex or {}
        meta.__fnewindex = meta.__fnewindex or setter
        meta.__newindex = function(_, k, v)
            local m = getmetatable(meta.__tnewindex)
            if m and m.__newindex then
                meta.__tnewindex[k] = v
            else
                setter(_, k, v)
            end
        end
    elseif type(setter) == 'table' then
        meta.__newindex = setter
    end
    return meta
end

function Meta.PushBackSetter(obj, setter)
    local meta = getmetatable(obj) or {}
    if meta.__newindex then
        local type = type(meta.__newindex)
        if type == 'function' then
            Meta.PushBackSetter(meta.__tnewindex, setter)
        elseif type == 'table' then
            Meta.PushBackSetter(meta.__newindex, setter)
        end
    else
        setmetatable(obj, SpawnSetter(meta, setter))
    end
    return obj
end

function Meta.PushFrontSetter(obj, setter)
    local meta = getmetatable(obj) or {}
    local onewindex = meta.__newindex
    if onewindex then
        local ofnewindex = meta.__fnewindex
        local otnewindex = meta.__tnewindex
        meta.__tnewindex = nil
        meta.__fnewindex = nil
        meta.__newindex = nil
        local nmeta = SpawnSetter(meta, setter)
        setmetatable(nmeta.__tnewindex or nmeta.__newindex, SpawnSetter({__tnewindex = otnewindex}, ofnewindex or onewindex))
        return setmetatable(obj, nmeta)
    else
        return setmetatable(obj, SpawnSetter(meta, setter))
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
    local l = meta.__newindex
    meta.__tnewindex = nmeta and nmeta.__tnewindex
    meta.__fnewindex = nmeta and nmeta.__fnewindex
    meta.__newindex = nmeta and nmeta.__newindex
    if not next(meta) then
        setmetatable(obj, nil)
    end
    return obj
end

return Meta