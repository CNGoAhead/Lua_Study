local Data = Class('Data')

function Data:Data()
    Property(self)
end

function Data:initData(data)
    for k, v in pairs(data) do
        if self:IsProp(k) then
            self[k] = v
        else
            self:addProp(k, v)
        end
    end
end

function Data:addProp(k, v, get, set)
    if self:IsProp(k) then
        -- WARN
    end

    Property(self, {name = k, default = v, flag = 'rw', Get = get, Set = set})
end

function Data:addPropG(k, v, get)
    Property(self, {name = k, default = v, flag = 'rw', Get = get})
end

function Data:addPropS(k, v, set)
    Property(self, {name = k, default = v, flag = 'rw', Set = set})
end

function Data:addPropR(k, v, get)
    Property(self, {name = k, default = v, flag = 'r', Get = get})
end

return Data