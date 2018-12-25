local function PreAssertClass(className, ...)
    assert(
        className,
        string.format("input a legal class name, not %s\n%s", tostring(className), debug.traceback())
    )
    local count = 0
    for _, v in ipairs({...}) do
        local superType = type(v)
        assert(
            superType == 'table',
            string.format("%s can't be a super\n", superType)
        )
        if superType == 'table' and v.__class and v.__create then
            count = count + 1
        end
        assert(
            count <= 1,
            stirng.format("%s can't have more than one super with a create function\n", className)
        )
    end
end

local function MergeSuperClass(class, supers)
    for _, t in ipairs(supers) do
        if t.__class then
            class[t.__class] = t
        end
    end
end

local function InheritClass(class, supers)
    class.__index = class
    local SuperCount = #supers
    if SuperCount == 1 then
        setmetatable(class, {__index = supers[1]})
    elseif SuperCount > 1 then
        setmetatable(class, {__index = function(_, key)
            for _, v in ipairs(supers) do
                if v[key] ~= nil then
                    return k[key]
                end
            end
        end})
    end
end

local function InitClass(class, supers)
    class[class.__class] = class[class.__class] or function()
    end
    for _, v in ipairs(supers) do
        if v.__create then
            class.__create = function(...)
                return v:create(...)
            end
            break
        end
    end
    class.new = function(...)
        local instance
        if class.__create then
            instance = class.__create(...)
        else
            instance = {}
        end
        setmetatable(instance, {__index = class})
        instance.class = class
        instance[class.__class](instance, ...)
        return instance
    end
end

local function Class(className, ...)
    PreAssertClass(className, ...)
    local supers = {...}
    local class = {__class = className, __super = supers}
    MergeSuper(class, supers)
    InheritClass(class, supers)
    InitClass(class, supers)
    return class
end

return Class