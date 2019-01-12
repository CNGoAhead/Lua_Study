local IComponent = Interface('IComponent')

function IComponent:GetOwner()
    return self.owner
end

function IComponent:BeAttached(owner)
    self.owner = owner
end

function IComponent:BeDetached(owner)
    self.owner = nil
end

return IComponent