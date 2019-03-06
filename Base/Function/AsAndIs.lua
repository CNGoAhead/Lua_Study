local function Is(obj, className)
    if obj.__class__ and obj.__super__ then
        obj.__is_map__ = obj.__is_map__ or {}

        if obj.__is_map__[className] ~= nil then
            return obj.__is_map__[className] ~= false
        end

        if obj.__class__ == className then
            obj.__is_map__[className] = obj
            return true
        else
            for _, v in ipairs(obj.__super__) do
                if Is(v, className) then
                    return true
                end
            end
        end

        obj.__is_map__[className] = false
    end
    return false
end

local function As(obj, className)
    if not obj.__is_map__ or obj.__is_map__[className] == nil then
        Is(obj, className)
    end
    return obj.__is_map__[className] or nil
end

return function()
    return Is, As
end
