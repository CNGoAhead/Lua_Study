require('GameEngine.CCNode')
require('GameEngine.Land')

local World = Class('World')

function World:Init()
    self._Actors = {}
    self._ActorFilter = {}
    self._Land = Land()
end

function World:SpawnActor(class, transform, ...)
    class = type(class) == 'string' and _G[class] or class
    local actor = class(...)
    local location = actor:SubClass('Location'):As('Location')
    location.x = transform.x or 0
    location.y = transform.y or 0
    location.z = transform.z or 0
    local ccnode = actor:SubClass('CCNode'):As('CCNode')
    self._Land:addChild(ccnode)
end

return World