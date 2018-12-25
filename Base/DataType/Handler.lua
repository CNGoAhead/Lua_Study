local function Handler(func, ...)
    assert(
        type(func) == 'function',
        'handler first param should be a function'
    )
    return function()
        return func(...)
    end
end