local function ToBind(t, k)
    local v = t[k]
    t[k] = nil
    t.__binder__ = t.__binder__ or {}
    Property(t, {
        name = k,
        default = v,
        flag = 'rw',
        OnChange = function(value)
            if t.__binder__ and t.__binder__[k] then
                for _, fs in pairs(t.__binder__[k]) do
                    for _, f in pairs(fs) do
                        f(value)
                    end
                end
            end
        end
    })
end

local function Bind(t, k, call, tag, callnow)
    if not t.__binder__ or not t:IsProp(k) then
        ToBind(t, k)
    end
    t.__binder__[k] = t.__binder__[k] or {}
    t.__binder__[k][tag] = t.__binder__[k][tag] or {}
    table.insert(t.__binder__[k][tag], call)
    if callnow then
        call(t[k])
    end
end

local function UnBind(t, k, tag)
    if t.__binder__ and t.__binder__[k] and t.__binder__[k][tag] then
        t.__binder__[k][tag] = nil
    end
end

return function()
    return Bind, UnBind
end