local function Clone(o, history)
    history = history or {}
    if history[o] then
        return history[o]
    end
    local r = {}
    history[o] = r
    for k, v in pairs(o) do
        if type(v) == 'table' then
            r[k] = Clone(v, history)
        else
            r[k] = v
        end
    end
    setmetatable(r, getmetatable(o))
    return r
end

return function()
    return Clone
end