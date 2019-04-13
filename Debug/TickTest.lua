require('Base.Init')
require('socket')


local log = Log.New()

local caetimer, caetick = require('Debug.Timer')()

local function Sleep(n)
    socket.select(nil, nil, n)
end

local tick = Ticker.New(0.01, 16)

tick:Begin()

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

for i=1, 1000000 do
    local d = tick:ConstraintDiff(math.random(0, 10000) * 0.0001 + 0.02)
    tick:SetTimer(
    function(diff)
        -- print(d, diff)
        -- assert(math.abs(diff - d) < 0.01)
    end,
    d,
    nil
)
end

-- for i = 1, 100000 do
--     local d = math.random(0, 10000) * 0.0001 + 0.02
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

-- local tree = RBTree.New(function(a, b)
--     return a.t < b.t
-- end,
-- function(a, b)
--     a.c = a.c + b.c
-- end
-- )

-- local test = {}
-- local test2 = {}

-- for i = 1, 200 do
--     table.insert(test, i)
-- end

-- for i = 1, 200 do
--     local k = math.random(1, 1000) % #test + 1
--     tree:Insert({t = test[k]})
--     table.insert(test2, {t = test[k]})
--     table.remove(test, k)
-- end

while 1 do
    -- for i=1,3 do
    --     local d = tick:ConstraintDiff(math.random(0, 10000) * 0.0001 + 0.02)
    --     -- caetimer.addTimer(
    --     tick:SetTimer(
    --     function(diff)
    --         print(d, diff)
    --         -- assert(math.abs(diff - d) < 0.01)
    --     end,
    --     d,
    --     nil
    -- )
    -- end
    now = socket.gettime()
    tick:Tick(now - last)
    -- caetick(now - last)
    -- assert(tree:Assert())
    -- local l = tree:LTop()
    -- print('L', l.t, l.c)
    -- local r = tree:RTop()
    -- print('R', r.t, r.c)
    -- local last
    -- for _, v in ipairs(tree:ToVector()) do
    --     if last then
    --         assert(v.t > last.t)
    --     end
    --     print(v.t, v.c)
    --     last = v
    -- end
    -- local k = math.random(1, 1000) % #test2 + 1
    -- print('Delete', test2[k].t)
    -- tree:Delete(test2[k])
    -- table.remove(test2, k)

    cost = cost + socket.gettime() - now
    count = count + 1
    print('cost / count = ', cost, count)
    if count >= 100 then
        break
    end
    last = now
    Sleep(0.001)
end

print('end')