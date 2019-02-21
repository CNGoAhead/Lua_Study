local Data = Class('Data')

Data.EBindType = Enum({Change = '__Change__', Set = '__Set__'})

Data.EBindKey = Enum({Any = '__Any__'})

function Data:Data()
    Property(self)
    self._event = {[Data.EBindType.Change] = {}, [Data.EBindType.Set] = {}}
    self._tagChange = {}
    self._eventTag = {}
    Event(self._event[Data.EBindType.Change], Data.EBindKey.Any)
    Event(self._event[Data.EBindType.Set], Data.EBindKey.Any)
end

function Data:InitData(data)
    for k, v in pairs(data) do
        if self:IsProp(k) then
            self[k] = v
        else
            self:AddProp(k, v)
        end
    end
end

function Data:Bind(k, tag, callback, callOnce, type)
    type = type or Data.EBindType.Change
    assert(Data.EBindType.IsIn(type))

    if self._event[type][k] then
        self._event[type][k] = self._event[type][k] + callback
        local key = '|' .. k .. '||' .. tostring(tag) .. '||' .. tostring(callback) .. '||' .. type .. '|'
        self._eventTag[key] = {k, tag, callback, type}
        if callOnce then
            callback(self.k)
        end
    end
end

function Data:Unbind(...)
    assert(..., 'unbind what?')
    local k = '.-'
    for i, v in ipairs({...}) do
        k = k .. '|' .. tostring(v) .. '|.-'
    end
    for key, value in pairs(self._eventTag) do
        if string.match(key, k) then
            self._event[value[4]][value[1]] = self._event[value[4]][value[1]] - value[3]
            self._eventTag[k] = nil
        end
    end
end

function Data:OnChange(key, ...)
    self._event[Data.EBindType.Change][key]:Call(...)
    self._event[Data.EBindType.Change][Data.EBindKey.Any]:Call(...)
end

function Data:OnSet(key, ...)
    self._event[Data.EBindType.Set][key]:Call(...)
    self._event[Data.EBindType.Set][Data.EBindKey.Any]:Call(...)
end

function Data:AddProp(k, v, get, set)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._event[Data.EBindType.Change], k)
    Event(self._event[Data.EBindType.Set], k)
    Property(self, {name = k, default = v, flag = 'rw', Get = get, Set = set, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
    self:OnChange(k, v)
    self:OnSet(k, v)
end

function Data:AddPropG(k, v, get)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._event[Data.EBindType.Change], k)
    Event(self._event[Data.EBindType.Set], k)
    Property(self, {name = k, default = v, flag = 'rw', Get = get, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
    self:OnChange(k, v)
    self:OnSet(k, v)
end

function Data:AddPropS(k, v, set)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._event[Data.EBindType.Change], k)
    Event(self._event[Data.EBindType.Set], k)
    Property(self, {name = k, default = v, flag = 'rw', Set = set, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
    self:OnChange(k, v)
    self:OnSet(k, v)
end

function Data:AddPropR(k, v, get)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._event[Data.EBindType.Change], k)
    Event(self._event[Data.EBindType.Set], k)
    Property(self, {name = k, default = v, flag = 'r', Get = get, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
    self:OnChange(k, v)
    self:OnSet(k, v)
end

return Data