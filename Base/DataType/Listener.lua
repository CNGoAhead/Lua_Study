local Handler = require('Base.Function.Handler')()

local Delegates = setmetatable({}, {__mode = 'v'})
local function Delegate(...)
    local params = {...}
    for k, v in ipairs(params) do
        params[k] = tostring(v)
    end
    local key = table.concat(params, '-')
    if not Delegates[key] then
        Delegates[key] = Handler(...)
    end
    return Delegates[key]
end

local MetaEvent = {__index = {__bIsEvent__ = true}}

local function Event()
    return setmetatable({}, MetaEvent)
end

function MetaEvent:__add(call)
    self[call] = true
    return self
end

function MetaEvent:__sub(call)
    self[call] = nil
    return self
end

function MetaEvent:__call(...)
    for c in pairs(self) do
        c(...)
    end
    return self
end

function MetaEvent:Clone()
    local newEvent = Event()
    for k, v in pairs(self) do
        newEvent[k] = v
    end
    return newEvent
end

local MetaListener = {}

function MetaListener:__newindex(k, v)
    local t = type(v)
    if t == 'table' and v.__bIsEvent__ then
        self.__events[k] = v
    elseif t == 'function' then
        self.__events[k] = Event() + v
    end
end
function MetaListener:__index(k)
    if not self.__events[k] then
        self.__events[k] = Event()
    end
    return self.__events[k]
end

local Listeners = setmetatable({}, {__mode = 'k'})
local function Listener(obj)
    if not Listeners[obj] then
        Listeners[obj] = setmetatable({__events = {}}, MetaListener)
    end
    return Listeners[obj]
end

return function()
    return Listener, Event, Delegate
end