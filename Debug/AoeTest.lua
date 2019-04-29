require('socket')
local Aoe = require('Base.Function.Aoe')

local poses = {}
for i = 1, 100000 do
    table.insert(poses, {math.random(-100, 100), math.random(-100, 100), math.random(0, 10)})
end
local posA = {math.random(-100, 100), math.random(-100, 100)}
local posB = {math.random(-100, 100), math.random(-100, 100)}
local radius = math.random(10, 50)
local angle = math.random(1, 359)

local now = socket.gettime()
local ret = nil
for i = 1, 100 do
    ret = Aoe.Sector(poses, posA, posB, radius, angle)
end
print('----LOG----:', socket.gettime() - now)

now = socket.gettime()
local ret2 = nil
for i = 1, 100 do
    ret2 = Aoe.Sector2(poses, posA, posB, radius, angle)
end
print('----LOG----:', socket.gettime() - now)
print(#ret, #ret2)