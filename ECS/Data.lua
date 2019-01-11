local Data = Class('Data')

Data.EBindType = Enum('Change', 'Set')

function Data:Data()
    Property(self)
    self._event = {}
    self._tagChange = {}
    self._tagSet = {}
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

function Data:Bind(k, tag, callback, type)
    type = type or Data.EBindType.Change

    self._event[type] = self._event[type] or {}
    if self._event[type][k] then
        self._event[type][k] = self._event[type][k] + callback
        local key = k .. tag .. callback .. type
        self._eventTag[key] = self._eventTag[key] or {}
        table.insert(self._eventTag[key], {k, tag, callback, type})
    end
end

function Data:Unbind(...)
    local k = '.*'
    for _, v in ipairs({...}) do
        k = k .. v
    end
    k = k .. '.*'
    for key, value in pairs(self._eventTag) do
        if string.find(key, k) then
            self._event[value[4]][value[1]] = self._event[value[4]][value[1]] - value[3]
            self._eventTag[k] = nil
        end
    end
end

function Data:OnChange(key, ...)
    self._event[Data.EBindType.Change][key][nil](...)
end

function Data:OnSet(key, ...)
    self._event[Data.EBindType.Set][key][nil](...)
end

function Data:AddProp(k, v, get, set)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._eventChange, k)
    Event(self._eventSet, k)
    Property(self, {name = k, default = v, flag = 'rw', Get = get, Set = set, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
end

function Data:AddPropG(k, v, get)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._eventChange, k)
    Event(self._eventSet, k)
    Property(self, {name = k, default = v, flag = 'rw', Get = get, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
end

function Data:AddPropS(k, v, set)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._eventChange, k)
    Event(self._eventSet, k)
    Property(self, {name = k, default = v, flag = 'rw', Set = set, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
end

function Data:AddPropR(k, v, get)
    if self:IsProp(k) then
        print('this property has exist')
    end

    Event(self._eventChange, k)
    Event(self._eventSet, k)
    Property(self, {name = k, default = v, flag = 'r', Get = get, OnChange = Handler(self.OnChange, self, k), OnSet = Handler(self.OnSet, self, k)})
end

return Data