local Property = require('Base.DataType.Property')

local function ToBind(t, k)
    local v = t[k]
    t[k] = nil
    t.__binder__ = t.__binder__ or {}
    Property(t, {
        name = k,
        default = v,
        flag = 'rw',
        OnChange = function(value)
            if t.__binder__[k] then
                for f, _ in pairs(t.__binder__[k]) do
                    f(value)
                end
            end
        end
    })
end

local function Bind(call, t, k, callnow)
    if not t.__binder__ or not t:IsProp(k) then
        ToBind(t, k)
    end
    t.__binder__[k] = t.__binder__[k] or {}
    t.__binder__[k][call] = true
    if callnow then
        call(t[k])
    end
end

local function UnBind(call, t, k)
    if t.__binder__ and t.__binder__[k] then
        t.__binder__[k][call] = nil
    end
end

return function()
    return Bind, UnBind
end