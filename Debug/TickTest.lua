require('Base.Init')
local socket = require('Debug.socket')

local caetimer, caetick = require('Debug.Timer')()

local function Sleep(n)
    -- socket.select(nil, nil, n)
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

local tree = RBTree.new(function(a, b)
    return a.t < b.t
end,
function(a, b)
    a.c = a.c + b.c
end
)

while 1 do
    now = socket.gettime()
    -- Tick.Tick()
    tree:Insert({t = math.random(1, 1000), c = math.random(1, 1000)})
    local l = tree:LTop()
    print('L', l.t, l.c)
    local r = tree:RTop()
    print('R', r.t, r.c)
    local last
    for _, v in ipairs(tree:ToVector()) do
        if last then
            assert(v.t > last.t)
        end
        print(v.t, v.c)
        last = v
    end
    print('Min Max', tree:MinMaxDep())
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