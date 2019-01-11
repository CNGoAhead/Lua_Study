local Enity = Class('Enity')

function Enity:Enity(...)
    self._components = {}
end

function Enity:AttachComponent(component)
    if not component:GetOwner() then
        table.insert(self._components, component)
        component:BeAttached(self)
    end
end

function Enity:DetachComponent(component)
    if component:GetOwner() == self then
        for _, v in ipairs(self._components) do
            if v == component then
                table.remove(self._components, v)
                component:BeDetached(self)
                break
            end
        end
    end
end

function Enity:GetComponents(class)
    if class then
        local components = {}
        for _, v in ipairs(self._components) do
            if Is(v, class) then
                table.insert(components, v)
            end
        end
        return components
    else
        return self._components
    end
end

return Enity