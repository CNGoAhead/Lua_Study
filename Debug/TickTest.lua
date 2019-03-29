require('Base.Init')
require('socket')

local caetimer, caetick = require('Debug.Timer')()

local function Sleep(n)
    socket.select(nil, nil, n)
end

Tick.Begin()

local now = socket.gettime()
local last = now
-- Tick.AddTick(
--     function(diff)
--     end
-- )

-- Tick.AddTick(
--     function(diff)
--         print(0.05, diff)
--     end,
--     nil,
--     0.05
-- )

-- Tick.AddTick(
--     function(diff)
--         print(0.5, diff)
--     end,
--     nil,
--     0.5
-- )

-- Tick.AddTick(
--     function(diff)
--         print(1, diff)
--     end,
--     nil,
--     1
-- )

-- Tick.AddTick(
--     function(diff)
--         print(3, diff)
--     end,
--     nil,
--     3
-- )

for i=1,5 do
    local d = math.random(0, 10000) * 0.0001 + 0.02
    Tick.AddTick(
    function(diff)
        print(d, diff)
        -- assert(math.abs(diff - d) < 0.01)
    end,
    nil,
    d
)
end

-- for i = 1, 1000000 do
--     local d = math.random(0, 10000) * 0.0001
--     caetimer.addTimer(
--     function(diff)
--         -- print(d, diff)
--     end,
--     d,
--     nil
-- )
-- end

print('over')

local count = 0
local cost = 0

while 1 do
    now = socket.gettime()
    Tick.Tick()

    -- caetick(socket.gettime() - now)
    cost = cost + socket.gettime() - now
    count = count + 1
    -- print('cost / count = ', cost, count)
    if count >= 100000 then
        break
    end
    last = now
    Sleep(0.01)
end