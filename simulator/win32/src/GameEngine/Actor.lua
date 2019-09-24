local Actor = Class('Actor')

function Actor:Init()
    self._Root = cc.Node:create()
    self:RegisterComponent(self)
end

function Actor:InheriteComponent(subClass, ...)
    subClass = type(subClass) == 'string' and _G[subClass] or subClass
    return self:SubClass(subClass, ...)
        :RegisterComponent(self:As(GetName(subClass)))
end

function Actor:AddComponent(component)
end

function Actor:RegisterComponent(component)
    return self
end

function Actor:BindLocation(component)
    local location = component:As('Location')
    if location then
        location:Bind('x', self.UpdateLocation, self, location)
        location:Bind('y', self.UpdateLocation, self, location)
        location:Bind('z', self.UpdateLocation, self, location)
    end
    return self
end

function Actor:UpdateLocation(location)
    if location:As('Location') then
        local y = location.y > 0 and math.sqrt(location.y) or 0
        self._Root:setPosition(location.x, y + location.z)
        self._Root:setScale(1 - y)
    end
    return self
end

return Actor