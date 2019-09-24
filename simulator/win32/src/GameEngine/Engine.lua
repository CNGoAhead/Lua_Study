require('Base.Init')
require('GameEngine.World')

local Engine = Class('Engine')

local _Instance

function Engine:Init()
    self._Ticker = Ticker.New(1/60, 16)
    self._Timer = Ticker.New(1/60, 16, true)
end

function Engine.GetInstance()
    _Instance = _Instance
    return _Instance
end

function Engine.DestroyInstance()
    _Instance = nil
end

function Engine:SpawnWorld(WorldClass)
    self._World = (WorldClass or World)()
end

function Engine:GetTimer()
    return self._Timer
end

function Engine:GetTicker()
    return self._Ticker
end

function Engine:GetWorld()
    return self._World
end