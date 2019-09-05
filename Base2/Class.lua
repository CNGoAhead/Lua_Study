-- {name = '|name||name|...'}
local StaticInheritMap = {}
-- {obj_instance = {obj = |name||name|...}}
local DynamicInheritMap = setmetatable({}, {__mode = 'k'})
-- {method_name = {}}
local MethodMap = {}
-- {struct_name = {Init}}
local StructMap = {}
-- {obj_instance = {struct_name = struct_instance}}
local StructInstanceMap = setmetatable({}, {__mode = 'k'})
-- {class_name = {method = {}, struct = {Init}}}
local ClassMap = {}

local Meta = require('Base2.Meta')()
local T = require('Base2.TString')()

local function IsObject(o)
    return not not StructInstanceMap[o]
end

local function GetInherits(cls)
    if IsObject(cls) then
        DynamicInheritMap[cls] = DynamicInheritMap[cls] or (T'|%1|' % tostring(cls))
        return DynamicInheritMap[cls]
    else
        local name = cls
        StaticInheritMap[name] = StaticInheritMap[name] or (T'|%1|' % name)
        return StaticInheritMap[name]
    end
end

local function AddInherit(name, inname)
    if StaticInheritMap[inname] then
        name:Swap(name + StaticInheritMap[inname])
    end
    if not string.find(tostring(name), '|'.. inname .. '|') then
        name:Swap(name + (T'|%1|' % tostring(inname)))
    end
    return name
end

local function Inherit(cls, ...)
    local innames = {...}
    local inherits = GetInherits(cls)
    for _, v in ipairs(innames) do
        AddInherit(inherits, v)
    end
end

local function Struct(name, ...)
    Inherit(name, ...)
    StructMap[name] = {
        Init = function(self)
        end
    }
    return StructMap[name]
end

local function Method(name, ...)
    Inherit(name, ...)
    MethodMap[name] = {}
    return MethodMap[name]
end

local function Class(name, ...)
    Inherit(name, ...)
    local struct = Struct(name)
    local method = Method(name)
    local meta = {}
    meta.__index = meta
    meta.__newindex = function(_, k, v)
        if k == 'Init' then
            struct.Init = v
        else
            method[k] = v
        end
    end
    ClassMap[name] = setmetatable({}, meta)
    return ClassMap[name]
end

local function NewMethod(name)
    if not MethodMap[name] then
        return
    end
    local method = {}
    for k, v in pairs(MethodMap[name]) do
        method[k] = v
    end
    return method
end

local function NewStruct(name)
    if not StructMap[name] then
        return
    end
    local struct = {}
    StructMap[name].Init(struct)
    return struct
end

local function As(obj, name)
    local ref = {__Object__ = obj, As = As, New = obj.New}
    obj = obj.__Object__ or obj
    if not IsObject(obj) then
        return
    end
    if not string.find(tostring(DynamicInheritMap[obj]), '|' .. name .. '|') then
        return
    end
    local method = MethodMap[name] or {}
    local struct = StructMap[name] and StructInstanceMap[obj][name] or {}
    local getter = function(_, k)
        return method[k] or struct[k]
    end
    return Meta.PushBackGetter(ref, getter)
end

local function New(...)
    local cnames = {...}
    local obj = {As = As, New = function()
        return New(unpack(cnames))
    end}
    StructInstanceMap[obj] = StructInstanceMap[obj] or {}
    Inherit(obj, ...)
    local MethodExistMap = {}
    local StructExistMap = {}
    local function AddParent(v)
        if MethodMap[v] and not MethodExistMap[v] then
            MethodExistMap[v] = true
            Meta.PushBackGetter(obj, NewMethod(v))
        end
        if StructMap[v] and not StructExistMap[v] then
            StructExistMap[v] = true
            StructInstanceMap[obj][v] = StructInstanceMap[obj][v] or NewStruct(v)
            Meta.PushBackGetter(obj, StructInstanceMap[obj][v])
        end
    end
    for _, v in ipairs(cnames) do
        if StaticInheritMap[v] then
            for n in string.gmatch(tostring(StaticInheritMap[v]), '|(.-)|') do
                AddParent(n)
            end
        end
    end
    return obj
end

return function()
    return Class, New, Method, Struct
end