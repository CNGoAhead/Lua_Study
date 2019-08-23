local Meta = require('Base.Function.Meta')()
local Listener, Event, Delegate = require('Base.DataType.Listener')()
local Handler = require('Base.Function.Handler')()
local T = require('Base.DataType.TString')()

local function encrypt(v, a, b)
    if type(v) == 'number' then
        return v * a + b
    else
        return v
    end
end

local function decrypt(v, a, b)
    if type(v) == 'number' then
        return (v - b) / a
    else
        return v
    end
end

local function SpawnAB(o)
    local k = tostring(o)
    local a = tonumber(string.sub(k, -2, -1), 16)
    local b = tonumber(string.sub(k, -4, -3), 16)
    return a ~= 0 and a or 7, b ~= 0 and b or 11
end

local function NewProp(p)
    local prop = {}
    prop.Listener = Listener(prop)
    prop.Tags = {}
    prop.A, prop.B = SpawnAB(prop)
    prop.Value = encrypt(p.Default, prop.A, prop.B)
    if string.find(p.Flag, 'r') then
        prop.Get = p.Get or function()
            return decrypt(prop.Value, prop.A, prop.B)
        end
    end
    if string.find(p.Flag, 'w') then
        prop.Set = p.Set or function(v)
            prop.Value = encrypt(v, prop.A, prop.B)
        end
    end
    return prop
end

local function Prop(p1, p2, p3, p4)
    return {Name = p1, Default = p2, Flag = 'rw', Get = p3, Set = p4}
end

local function PropS(p1, p2, p3)
    return {Name = p1, Default = p2, Flag = 'rw', Set = p3}
end

local function PropG(p1, p2, p3)
    return {Name = p1, Flag = 'r', Default = p2, Get = p3}
end

local function PropR(p1, p2)
    return {Name = p1, Flag = 'r', Default = p2}
end

local PropertyInstances = setmetatable({}, {__mode = 'k'})

local function Getter(t, k)
    local p = PropertyInstances[t] and PropertyInstances[t][k]
    if p and p.Get then
        local listener = p.Listener
        listener.PreGet()
        local value = p.Get()
        listener.AftGet()
        listener.OnGet()
        return value
    end
end

local function Setter(t, k, v)
    local p = PropertyInstances[t] and PropertyInstances[t][k]
    if p and p.Set then
        local listener = p.Listener
        listener.PreSet()
        if p.Get and p.Get() ~= v then
            p.Set(v)
            listener.OnChange()
        end
        listener.AftSet()
        listener.OnSet()
    end
    return true
end

local function RawGet(t, k)
    local p = PropertyInstances[t] and PropertyInstances[t][k]
    if p then
        return decrypt(p.Value, p.A, p.B)
    end
end

local function RawSet(t, k, v)
    local p = PropertyInstances[t] and PropertyInstances[t][k]
    if p then
        p.Value = encrypt(v, p.A, p.B)
    end
end

local function Bind(t, k, ...)
    local p = PropertyInstances[t] and PropertyInstances[t][k]
    if p then
        local delegate = Delegate(...)
        p.Listener.OnChange =
        p.Listener.OnChange + delegate
        return delegate
    end
    return Handler(print, T'bind err, property: %1 !' % k),
    print(T'bind err, property: %1 !' % k)
end

local function Unbind(t, k, ...)
    local p = PropertyInstances[t] and PropertyInstances[t][k]
    if p then
        local delegate = Delegate(...)
        p.Listener.OnChange =
        p.Listener.OnChange - delegate
        return delegate
    end
    return Handler(print, T'unbind err, property: %1 !' % k),
    print(T'unbind err, property: %1 !' % k)
end

local function BindTag(t, k, tag, ...)
    local p = PropertyInstances[t] and PropertyInstances[t][k]
    if p then
        p.Tags[tag] = p or {}
        local delegate = t:Bind(k, ...)
        table.insert(p.Tags[tag], delegate)
        return delegate
    end
    return Handler(print, T'bind tag err, property: %1 !' % k),
    print(T'bind tag err, property: %1 !' % k)
end

local function UnbindTag(t, k, tag)
    if not tag then
        tag, k = k, tag
    end
    local group = PropertyInstances[t] and (k and {PropertyInstances[t][k]} or PropertyInstances[t])
    for _, p in pairs(group or {}) do
        if p.Tags and p.Tags[tag] then
            for _, v in ipairs(p.Tags[tag]) do
                p.Listener.OnChange =
                p.Listener.OnChange - v
            end
            p.Tags[tag] = nil
        end
    end
end

local function GetListner(t, k)
    return PropertyInstances[t] and PropertyInstances[t][k] and PropertyInstances[t][k].Listener
end

local function Pairs(t)
    local ps = PropertyInstances[t]
    local function itr(o, i)
        i = next(ps, i)
        local v = o[i]
        return v and i, v
    end
    return itr, t
end

local function IPairs(t)
    local function itr(o, i)
        i = (i or 0) + 1
        local v = o[i]
        return v and i, v
    end
    return itr, t
end

local function Has(t, k)
    local ps = PropertyInstances[t]
    return not not (ps and ps[k])
end

local function Property(obj, ...)
    local props = {...}
    if not PropertyInstances[obj] then
        Meta.PushFrontGetter(obj, Getter)
        Meta.PushFrontSetter(obj, Setter)
        PropertyInstances[obj] = {}
        table.insert(props, PropR('RawGet', RawGet))
        table.insert(props, PropR('RawSet', RawSet))
        table.insert(props, PropR('Bind', Bind))
        table.insert(props, PropR('Unbind', Unbind))
        table.insert(props, PropR('BindTag', BindTag))
        table.insert(props, PropR('UnbindTag', UnbindTag))
        table.insert(props, PropR('Listener', GetListner))
        table.insert(props, PropR('Pairs', Pairs))
        table.insert(props, PropR('IPairs', IPairs))
        table.insert(props, PropR('Has', Has))
    end
    for _, v in ipairs(props) do
        PropertyInstances[obj][v.Name] = NewProp(v)
    end
end

return function()
    return Property, Prop, PropR, PropG, PropS
end