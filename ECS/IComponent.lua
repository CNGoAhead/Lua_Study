local IComponent = Interface('IComponent')

function IComponent:GetOwner()
    return self._owner
end

function IComponent:BeAttached(owner)
    self._owner = owner
end

function IComponent:BeDetached(owner)
    self._owner = nil
end

return IComponent