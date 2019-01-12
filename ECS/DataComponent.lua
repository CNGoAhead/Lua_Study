local Data = require('ECS.Data')
local IComponent = require('ECS.IComponent')
local DataComponent = Class('DataComponent', Data, IComponent)

function DataCompoent:DataComponent()
    self:AddProp('owner', owner)
    self:AddProp('bIsBeginPlay', false)
    self:Bind('bIsBeginPlay', self, function()
        self:BeginPlay()
    end)
end

function DataCompoent:BeginPlay()
end

function DataComponent:GetOwner()
    return self.owner
end

function DataCompoent:BeAttached(owner)
    self.owner = owner
    self.owner:Bind('bIsBeginPlay', self, function()
        self.bIsBeginPlay = self.owner.bIsBeginPlay
    end, true)
end

function DataCompoent:BeDetached(owner)
    self.owner:Unbind('bIsBeginPlay', self)
    self.owner = nil
end

return DataComponent