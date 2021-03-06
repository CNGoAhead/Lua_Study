local function Handler(func, param, ...)
    assert(
        type(func) == 'function',
        'handler first param should be a function'
    )
    if next({...}) then
        return Handler(function(...)
            return func(param, ...)
        end, ...)
    else
        return function(...)
            return func(param, ...)
        end
    end
end

return function()
    return Handler
end