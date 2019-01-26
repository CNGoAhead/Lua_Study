local Ground = Class('Ground', Pos)

function Ground:Ground()
    self.x = 0
    self.y = 0
    self.height = 0
    return self
end

function Ground:Init(x, y, height)
    self.x = x
    self.y = y
    self.height = height
    return self
end

return Ground