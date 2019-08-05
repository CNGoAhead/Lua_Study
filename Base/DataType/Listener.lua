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

local MetaEvent = {}

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

local function Event()
    return setmetatable({}, MetaEvent)
end

local MetaListener = {}

function MetaListener:__newindex(k, v)
    self.__events[k] = Event()
    if v then
        self.__events[k][v] = true
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