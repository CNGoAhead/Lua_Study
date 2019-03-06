local function Enum(...)
    local enumElements
    if type(...) ~= "table" then    --允许enum("EnumType1", "EnumType2")的使用形式
        enumElements = {...}
    else
        enumElements = ...
    end
    local newElements
    for i, v in pairs(enumElements) do  --如果传入的是数组如{"EnumType1", "EnumType2"}会转换为{"EnumType1" = 1, "EnumType2" = 2}
        if type(i) == "number" then
            newElements = newElements or {}
            newElements[v] = i
        end
    end
    enumElements = newElements or enumElements
    local e = {}
    e.Pairs = function()
        return pairs(enumElements)
    end
    e.IsIn = function(i)
        for _, v in pairs(enumElements) do
            if v == i then
                return true
            end
        end
        return false
    end
    e.Count = function()
        return #enumElements
    end
    e.Max = function()
        local max
        for _, v in pairs(enumElements) do
            if not max or v > max then
                max = v
            end
        end
        return max
    end
    e.Min = function()
        local min
        for _, v in pairs(enumElements) do
            if not min or v < min then
                min = v
            end
        end
        return min
    end
    setmetatable(e,
    {
        __index = function(_, key)
            return enumElements[key]
        end,
        __newindex = function()
            print("Enum is read-only!!!")
        end
    })
    return e
end

return function()
    return Enum
end