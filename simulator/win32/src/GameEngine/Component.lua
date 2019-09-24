Class('Engine')
local Component = Class('Component', Class('DisplayName'))

function Component:Component()
    self:InitComponent()
end

function Component:Init()
    Property(self,
    Prop('Owner', nil),
    Prop('bIsActive', true),
    Prop('bTick', false),
    PropR('OnAttach', Listener(self).OnAttach),
    PropR('OnUnAttach', Listener(self).OnUnAttach),
    PropR('OnActive', Listener(self).OnActive),
    PropR('OnDeActive', Listener(self).OnDeActive)
    )
end

function Component:InitComponent()
    self:As('Component'):Bind('bIsActive', self.OnActiveChange, self)()
    self:As('Component'):Bind('bTick', self.OnTickChange, self)()
end

function Component:OnActiveChange()
    if self.bIsActive then
        self:Active()
    else
        self:DeActive()
    end
end

function Component:OnTickChange()
    local ticker =  Engine.GetInstance():GetTicker()
    local component = self:As('Component')
    if component.bTick then
        component.__ticker__ = component.__ticker__ or ticker:SetTicker(Handler(self.TickComponent, self))
    elseif self:As('Component').__ticker__ then
        ticker:RemoveTimer(component.__ticker__)
    end
end

function Component:AttachTo(actor)
    if self.Owner then
        self.Owner:RemoveComponent(self)
    end
    self.Owner = actor
    self.OnAttach()
    if self.bIsActive then
        self:Active()
    end
end

function Component:UnAttach(actor)
    self.Owner = nil
    self.OnUnAttach()
end

function Component:TickComponent(diff)
end

function Component:Active()
end

function Component:DeActive()
end

return Component