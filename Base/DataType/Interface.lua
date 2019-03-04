local function PreAssertInterface(interfaceName, ...)
    assert(
        interfaceName,
        string.format("input a legal interface name, not %s\n%s", tostring(interfaceName), debug.traceback())
    )
    local count = 0
    for _, v in ipairs({...}) do
        local superType = type(v)
        assert(
            superType == 'table',
            string.format("%s can't be a super\n", superType)
        )
        if superType == 'table' and v.__class__ and v.__create__ then
            count = count + 1
        end
        assert(
            count == 0,
            string.format("%s can't have more than one super with a create function\n", interfaceName)
        )
    end
end

local function MergeInterface(interface, supers)
    for _, t in pairs(supers) do
        for k, v in pairs(t) do
            assert(
                type(v) == 'function',
                string.format("interface just inherit function")
            )
            assert(
                interface[k] == nil,
                string.format("has same interface :%s", k)
            )
            interface[k] = v
        end
    end
end

local function Interface(interfaceName, ...)
    PreAssertInterface(interfaceName, ...)
    local supers = {...}
    local interface = {__class__ = interfaceName, __super__ = supers}
    MergeInterface(interface, supers)
    return interface
end

return Interface