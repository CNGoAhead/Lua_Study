local Land = Class('Land')

function Land:Init(width, height)
    self._Root = cc.Node:create()
    self._Root:setContentSize(cc.size(width, height))
    Property(self,
        PropR('width', width),
        PropR('height', height)
    )
end

return Land