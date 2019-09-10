local a = nil
local a = {1,2,3}
local a = {[1] = 1, [2] = 2, [3] = 3}
local a = {a = 1, b = 2, c = 3}
local a = {}
self = this


local Cron = require('Base.Cron.Cron')

function a:a()
end

function a.a(self)
end

a:a()
a.a(a)