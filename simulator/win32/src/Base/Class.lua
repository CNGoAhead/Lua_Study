-- {name = '|name||name|...'}   用于记录 Class|Struct|Method 继承了哪些 Class|Struct|Method 以及继承的顺序
local StaticInheritMap = {}
-- {obj_instance = {obj = |name||name|...}} 用于记录 Object 继承了哪些 Object|Class|Struct|Method 以及继承的顺序
local DynamicInheritMap = setmetatable({}, {__mode = 'k'})
-- {method_name = {}}
local MethodMap = {}
-- {struct_name = {Init}}
local StructMap = {}
-- {obj_instance = {method_name = method_instance}}
local MethodInstanceMap = setmetatable({}, {__mode = 'k'})
-- {obj_instance = {struct_name = struct_instance}}
local StructInstanceMap = setmetatable({}, {__mode = 'k'})
-- {class_name = {method = {}, struct = {Init}}}
local ClassMap = {}

local Meta = require('Base.Meta')()
local T = require('Base.TString')()
local Clone = require('Base.Clone')()

local function IsObject(o)
    return not not StructInstanceMap[o]
end

local function GetInherits(cls)
    if IsObject(cls) then
        DynamicInheritMap[cls] = DynamicInheritMap[cls] or T''
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

local function As(obj, name)
    local ref = {__Object__ = obj, As = As, New = obj.New}
    obj = obj.__Object__ or obj
    if not IsObject(obj) then
        return
    end
    if not string.find(tostring(DynamicInheritMap[obj]), '|' .. name .. '|') then
        return
    end
    return Meta.PushBackGetter(ref, MethodInstanceMap[obj][name] or StructInstanceMap[obj][name])
end

local function NewMethod(name)
    if not MethodMap[name] then
        return
    end
    return Clone(MethodMap[name])
end

local function NewStruct(name, ...)
    if not StructMap[name] then
        return
    end
    local struct = {}
    StructMap[name].Init(struct, ...)
    return struct
end

local MethodExistMap = {}
local StructExistMap = {}

local function AddMehodAndStruct(obj, v, ...)
    if MethodMap[v] and not MethodExistMap[v] then
        MethodExistMap[v] = true
        MethodInstanceMap[obj][v] = MethodInstanceMap[obj][v] or NewMethod(v)
        Meta.PushBackGetter(obj, MethodInstanceMap[obj][v])
    end
    if StructMap[v] and not StructExistMap[v] then
        StructExistMap[v] = true
        StructInstanceMap[obj][v] = StructInstanceMap[obj][v] or NewStruct(v, ...)
        Meta.PushBackGetter(obj, StructInstanceMap[obj][v])
    end
    return obj
end

local function SubClass(obj, cname, params, ...)
    if not IsObject(obj) then
        return
    end
    if string.find(tostring(DynamicInheritMap[obj]), '|' .. cname .. '|') then
        return obj
    end
    if ... then
        params = {[cname] = {params, ...}}
    end
    MethodExistMap = {}
    StructExistMap = {}
    if StaticInheritMap[cname] then
        Inherit(obj, cname)
        for n in string.gmatch(tostring(StaticInheritMap[cname]), '|(.-)|') do
            AddMehodAndStruct(obj, n, unpack(params[n]))
        end
        if ClassMap[cname] then
            ClassMap[cname][cname](obj, unpack(params[cname]))
        end
    end
    return obj
end

local function New(cname, ...)
    local obj = {
        As = As,
        SubClass = SubClass,
        New = function(...)
            return New(cname, ...)
        end
    }
    MethodExistMap = {}
    StructExistMap = {}
    StructInstanceMap[obj] = StructInstanceMap[obj] or {}
    MethodInstanceMap[obj] = MethodInstanceMap[obj] or {}
    if StaticInheritMap[cname] then
        local class
        Inherit(obj, cname)
        for n in string.gmatch(tostring(StaticInheritMap[cname]), '|(.-)|') do
            AddMehodAndStruct(obj, n, ...)
            class = class or (ClassMap[n] and n)
        end
    end
    return obj
end

local function Register(name, method)
    _G[name] = _G[name] or setmetatable({}, {__call = function(_, ...)
        return New({[name] = {...}})
    end})
    if method then
        Meta.PushBackGetter(_G[name], method)
        Meta.PushBackSetter(_G[name], method)
    end
end

local function Struct(name, ...)
    Inherit(name, ...)
    if not StructMap[name] then
        Register(name)
        StructMap[name] = setmetatable({
            Init = function(_)
            end
        }, {__call = function(_, ...)
            return New({[name] = {...}})
        end})
    end
    return StructMap[name]
end

local function Method(name, ...)
    Inherit(name, ...)
    if not MethodMap[name] then
        MethodMap[name] = {__Method__ = name}
        Register(name, MethodMap[name])
    end
    return MethodMap[name]
end

local function Class(name, ...)
    Inherit(name, ...)
    if not ClassMap[name] then
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
        meta.__call = function(_, ...)
            return New({[name] = {...}})
        end
        ClassMap[name] = setmetatable({
            __Class__ = name,
            [name] = function()
            end
        }, meta)
    end
    return ClassMap[name]
end

local function GetName(obj)
    if DynamicInheritMap[obj] or StaticInheritMap[obj] then
        return (GetInherits(obj) / '|(.-)|')[1]
    end
end

return function()
    return Class, New, Method, Struct, GetName
end