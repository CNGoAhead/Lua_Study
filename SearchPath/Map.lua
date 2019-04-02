local Ground = require('SearchPath.Ground')
local Map = Class('Map')

function Map:Map()
    self.width = 0
    self.height = 0
    self.grounds = {}
    return self
end

function Map:GetIndex(x, y)
    if x > 0 and x <= self.width and y > 0 and y <= self.height then
        return (y - 1) * self.width + x
    else
        return -1
    end
end

function Map:GetPos(index)
    local x = index % self.width
    x = x == 0 and self.width or x
    local y = math.floor((index - 1) / self.width) + 1
    return x, y
end

function Map:Init(width, height)
    self.width = width
    self.height = height
    for i = 1, self.width * self.height do
        local x, y = self:GetPos(i)
        table.insert(self.grounds, Ground.New():Init(x, y, math.floor(math.random() + 0.2)))
    end
    return self
end

function Map:GetGround(index)
    return self.grounds[index]
end

return Map