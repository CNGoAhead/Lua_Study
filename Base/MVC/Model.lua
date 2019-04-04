local Model = Class('Model')

Model.EBindType = Enum({Change = '__Change__', Set = '__Set__'})

Model.EBindKey = Enum({Any = '__Any__'})

function Model:Model()
    Property(self)
    self._event = {[Model.EBindType.Change] = {}, [Model.EBindType.Set] = {}}
    self._tagChange = {}
    self._eventTag = {}
    Event(self._event[Model.EBindType.Change], Model.EBindKey.Any)
    Event(self._event[Model.EBindType.Set], Model.EBindKey.Any)
end

function Model:InitModel(model)
    for k, v in pairs(model) do
        if self:IsProp(k) then
            self[k] = v
        else
            self:AddProp(k, v)
        end
    end
end

function Model:Bind(k, tag, callback, callOnce, type)
    type = type or Model.EBindType.Change
    assert(Model.EBindType.IsIn(type))

    if self._event[type][k] then
        self._event[type][k] = self._event[type][k] + callback
        local key = '|' .. k .. '||' .. tostring(tag) .. '||' .. tostring(callback) .. '||' .. type .. '|'
        self._eventTag[key] = {k, tag, callback, type}
        if callOnce then
            callback(self.k)
        end
    end
end

function Model:Unbind(...)
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

function Model:OnChange(key, ...)
    self._event[Model.EBindType.Change][key]:Call(...)
    self._event[Model.EBindType.Change][Model.EBindKey.Any]:Call(...)
end

function Model:OnSet(key, ...)
    self._event[Model.EBindType.Set][key]:Call(...)
    self._event[Model.EBindType.Set][Model.EBindKey.Any]:Call(...)
end

function Model:AddProp(k, v, get, set)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._event[Model.EBindType.Change], k)
    Event(self._event[Model.EBindType.Set], k)
    Property(self, {name = k, default = v, flag = 'rw', Get = get, Set = set, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
    self:OnChange(k, v)
    self:OnSet(k, v)
end

function Model:AddPropG(k, v, get)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._event[Model.EBindType.Change], k)
    Event(self._event[Model.EBindType.Set], k)
    Property(self, {name = k, default = v, flag = 'rw', Get = get, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
    self:OnChange(k, v)
    self:OnSet(k, v)
end

function Model:AddPropS(k, v, set)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._event[Model.EBindType.Change], k)
    Event(self._event[Model.EBindType.Set], k)
    Property(self, {name = k, default = v, flag = 'rw', Set = set, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
    self:OnChange(k, v)
    self:OnSet(k, v)
end

function Model:AddPropR(k, v, get)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._event[Model.EBindType.Change], k)
    Event(self._event[Model.EBindType.Set], k)
    Property(self, {name = k, default = v, flag = 'r', Get = get, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
    self:OnChange(k, v)
    self:OnSet(k, v)
end

return Model