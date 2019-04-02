local Nav, NavSys = require('Nav.Nav')()

require("socket")
local function Sleep(n)
socket.select(nil, nil, n)
end

local alien = require('alien')
-- local nav1 = alien.load('Navigation1.dll')
-- local nav = alien.load('Navigation.dll')

local nav = Nav.Create()

-- local Init1 = nav1.Init
-- Init1:types('void', 'int', 'int', 'pointer')
-- local Search1 = nav1.Search
-- Search1:types('int', 'pointer', 'int', 'int', 'int', 'int', 'int', 'int')

local test = require('Debug.BattleMap')

-- local Init = nav.Init
-- Init:types('void', 'int', 'int', 'pointer', 'int', 'pointer', 'int')
-- local Search = nav.Search
-- Search:types('int', 'pointer', 'int', 'int', 'int', 'int', 'int', 'int', 'int')
-- local MultiSearch = nav.MultiSearch
-- MultiSearch:types('int', 'pointer', 'int', 'int', 'pointer', 'int', 'int', 'int', 'int')
-- local FlagSearch = nav.FlagSearch
-- FlagSearch:types('int', 'pointer', 'int', 'int', 'short', 'int', 'int', 'int')

local width = 42
local height = 42
local array = alien.array('int', width * height)
local hs = alien.array('int', width * height * 3)
local fs = alien.array('int', {
    math.random(0, width - 1), math.random(0, height - 1), 1,
    math.random(0, width - 1), math.random(0, height - 1), 1,
    math.random(0, width - 1), math.random(0, height - 1), 1,
    math.random(0, width - 1), math.random(0, height - 1), 1,
    math.random(0, width - 1), math.random(0, height - 1), 1,
    math.random(0, width - 1), math.random(0, height - 1), 2,
    math.random(0, width - 1), math.random(0, height - 1), 2,
    math.random(0, width - 1), math.random(0, height - 1), 2,
    math.random(0, width - 1), math.random(0, height - 1), 2,
    math.random(0, width - 1), math.random(0, height - 1), 3,
    math.random(0, width - 1), math.random(0, height - 1), 3,
    math.random(0, width - 1), math.random(0, height - 1), 3,
})

local f = {}

for i=1,10 do
    f[nav:GetIndex(math.random(0, width - 1), math.random(0, height - 1))] = math.random(1, 3)
end

local hl = 0
local fl = 12
local map = {
   00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,99,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,99,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,99,00,00,00,00, 
   00,00,00,00,99,99,99,99,99,99,99,99,99,99,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,99,00,00,00,00, 
   00,00,00,00,99,00,00,00,00,00,00,00,00,00,99,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,99,00,00,00,00, 
   00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,99,99,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,99,00,00,00,00, 
   00,00,00,00,99,00,00,00,00,00,00,00,99,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,99,00,00,00,00, 
   00,00,00,00,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,99,99,99,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,99,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,99,99,99,99,99,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,99,99,99,99,99,00,00,00,00,99,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,99,00,00,00,99,00,00,00,00,99,00,00,00,00,00,00,00,99,99,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,99,99,00,00,00,99,00,00,00,00,99,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,99,00,00,00,00,99,00,00,00,00,99,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,99,00,00,00,00,99,00,00,00,00,99,99,99,99,99,99,99,00,00,99,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,99,99,99,99,99,99,00,00,00,00,99,00,00,00,00,00,99,00,00,99,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,99,99,99,99,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,99,99,99,99,99,99,99,99, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,99,99,99,99,99,99,99,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,99,00,00,00,00,00,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,99,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,99,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,99,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,99,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,99,99,99,00,00,00,99,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,99,00,00,00,99,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,99,99,00,00,99,00,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,99,00,00,00,00,00,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,99,99,99,99,99,99,99,99,99,99,99,99,99,99,00,00,00,00,00,00,00,00,99,99,99,99,99,99,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,99,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,99,00,00,00,00,00, 
   00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,99,00,00,00,00,99,00,00,00,00,00, 
}

test:ctor(width - 2)
test:init(require('Debug.GameMap'))

local h = {}

for i, v in ipairs(map) do
    array[i] = math.max(math.random(0, 1000) - 500, 0) / 5
    h[i - 1] = array[i]
    if array[i] > 0 then
        hs[hl * 3 + 1] = (i - 1) % width
        hs[hl * 3 + 2] = math.floor((i - 1) / width)
        hs[hl * 3 + 3] = array[i]
        hl = hl + 1
        test:addBattler({bid = 50, data = {hp = array[i]}, info = {btype = 0}, vstate = {edge = 1, bgx = (i - 1) % width, bgy = math.ceil((i - 1) / width), gsize = 1}})
    end
end

-- Init1(width, height, array.buffer)
-- Init(width, height, hs.buffer, hl, fs.buffer, fl)
nav:Init(width, height)

nav:UpdateHeight(h)

nav:UpdateFlag(f)

local x = {}
local y = {}

local count = 0

local ends = alien.array('int', 20)

local s = 0

local ps = {}

while 1 do
    local sx = math.random(0, width - 1)
    local sy = math.random(0, height - 1)
    -- local len = math.random(1, 10)
    -- for i=1, len do
    --     local ex = math.random(0, width - 1)
    --     local ey = math.random(0, height - 1)
    --     ends[i * 2 - 1] = ex
    --     ends[i * 2] = ey
    -- end
    local ex = math.random(0, width - 1)
    local ey = math.random(0, height - 1)

-- local t = socket.gettime()
--     table.insert(ps, NavSys.AddCmd(NavSys.ENavCmd.Search, nav, sx, sy, ex, ey, 1, 1, -1))
-- s = s + socket.gettime() - t

    -- if count <= 100 then
    --     table.insert(x, sx)
    --     table.insert(x, ex)
    --     table.insert(y, sy)
    --     table.insert(y, ey)
    -- else
    --     ex = x[math.random(1, #x)]
    --     ey = y[math.random(1, #y)]
    -- end
    -- local sx = 0
    -- local sy = 0
    -- local ex = width - 1
    -- local ey = height - 1
    -- print(sx, sy, ex, ey)
    -- local len = Search1(array.buffer, sx, sy, ex, ey, 1, 1)
    -- local t = socket.gettime()
    -- local len = MultiSearch(array.buffer, sx, sy, ends.buffer, len, 1, 1, -1)
    -- local len = Search(array.buffer, sx, sy, ex, ey, 1, 1, -1)
    -- local len = FlagSearch(array.buffer, sx, sy, math.random(1, 3), 1, 1, -1)
    -- local path = nav:Search(sx, sy, ex, ey, 1, 1)
    -- s = s + socket.gettime() - t
    -- if sx == ex and sy == ey then
    --     print('is in end')
    -- elseif type(path) == 'number' then
    --     print('error code = ' .. path)
    -- else
    --     local t = {}
    --     for i, v in ipairs(path) do
    --         t[i] = v.x .. '-' .. v.y
    --     end
    --     print(table.concat(t, ","))
    -- end
    -- print(socket.gettime() - s)
    -- local t = {}
    -- local oindex, index = array[1], array[1]
    -- local dir
    -- local i = 1
    -- while i <= len do
    --     oindex = index
    --     index = array[i]
    --     local d = index - oindex
    --     if dir ~= d then
    --         if dir ~= 0 then
    --             table.insert(t, {array[i] % width, math.ceil(array[i] / width)})
    --         end
    --         dir = d
    --     end
    --     i = i + 1
    -- end
    -- for i, v in ipairs(t) do
    --     t[i] = test:getAstarKey(v[1], v[2])
    -- end
    -- for i=1,len do
    --     t[i] = array[i]
    -- end
    -- print(table.concat(t, ","))
    local t = socket.gettime()
    local path2 = test:searchPathUsingAstarSample(sx, sy, ex, ey)
    s = s + socket.gettime() - t
    -- for i, v in ipairs(path2) do
    --     path2[i] = test:getAstarKey(v[1], v[2])
    -- end
    -- print(table.concat(path2, ','))
    -- local len = Search(array.buffer, sx, sy, ex, ey, 1, 1)
    -- local t = {}
    -- for i=1, len do
    --     table.insert(t, array[i])
    -- end
    -- print(table.concat(t, ","))

    count = count + 1
    -- Sleep(1)
    -- if count ~= 0 and count % 1000 == 0 then
    --     Sleep(3)
    -- end
    -- print(count)
    if count >= 10000 then
        -- print(s)
        break
    end
end

-- local t = socket.gettime()
-- NavSys.Tick()
-- s = s + socket.gettime() - t

-- for _, v in ipairs(ps) do
--     local path = NavSys.GetPath(v)
--     if type(path) == 'number' then
--         print('error code = ' .. path)
--     else
--         local t = {}
--         for i, v in ipairs(path) do
--             t[i] = v.x .. '-' .. v.y
--         end
--         print(table.concat(t, ","))
--     end
-- end

print(s)

if true then
    return
end

require('Base.Init')
require('Json.dkjson')

local TickUp = Interface('TickUp')

function TickUp:TickUp()
end

function TickUp:Tick()
    if self.value then
        self.value = self.value + 1
    end
end

local PT = Class('PT')

function PT:PT()
    print('create PT')
end

local T = Class('T', PT)

function T:T()
    print('create T')
end

local Test = Class('Test', T, TickUp)

function Test:Test()
    Event(self, 'OnChange')
    Property(self,
        {
            name = 'value',
            default = -90,
            flag = 'rw',
            OnChange = function()
                print('on change', self:PropGet('value'))
                self.OnChange[nil]()
            end,
            OnSet = function()
                print('on set ' .. self:PropGet('value'))
                self.OnSet[nil]()
            end,
            Get = function()
                print('get' .. self:PropGet('value'))
                return self:PropGet('value')
            end,
            Set = function(value)
                print('set' .. value)
                self:PropSet('value', value)
            end
        }
    )
    Event(self, 'OnSet')
    self.OnChange = function()
        print('event on change 1')
    end
    self.OnSet = function()
        print('event on set 1')
    end
    self.OnChange = self.OnChange + function()
        print('event on change 2')
    end
    self.OnSet = self.OnSet + function()
        print('event on set 2')
    end
end

local p1 = 2
local p2 = 3
local p3 = 4
local p4 = 5

local t = Test.New()

function a(b, c, d)
    print(b, c, d)
end

local h = Handler(a, nil, 1)

local function decodeSeasonId(id)
    local mouth = id % 90
    local year = (id - mouth) / 90
    return year, mouth
end

local function getSeasonId(diff)
    diff = diff or 0
    local now = os.time()

    local date = os.date("!*t", now)

    local mday = date.day --一个月中的第几天      (01-31)
    local wday = date.wday --一个星期中的第几天    (1-7)(周日-周六)
    wday = (wday - 1) % 7
    wday = wday == 0 and 7 or wday

    local year = date.year
    local month = date.month + diff

    if mday < 7 and mday < wday then
        --现在还是上个月的赛季延续，也就是说上个月才是现在的赛季ID
        month = month - 1
        month = (month + 11) % 12 + 1
        year = year - math.floor(month / 12)
    end

    --赛季ID = 年 * 90 + 月
    return year * 90 + month
end

local function getMouthlyRankEndTime()
    local y, m = decodeSeasonId(getSeasonId())
    return os.time({year = y, month = m, day = 1, hour = 0, min = 0, sec = 0})
end

local Data = require('ECS.Data')

local d = Data.New()

d:AddProp('prop', 1)

for i = 1, 10000 do
    d:Bind('prop', i, function()
        -- print(i)
    end)
end

d.prop = 2

print('----LOG----:unbind')

d:Unbind('prop', 1)

d.prop = 3

local Map = require('SearchPath.Map')



local BinHeap = require('SearchPath.BinHeap')

local heap = BinHeap.New():Init()

for i = 1, 1000 do
    heap:Add(math.random(1, 90))
end

local SearchPath = require('SearchPath.SearchPath')

local iiii = 1

local map
for i = 1, 82 do
    map = Map.New():Init(90, 90)
end

while 1 do
    print('----RUN----')
    local m = {}
    -- local map = Map.New():Init(90, 90)
    map:GetGround(map:GetIndex(1, map.width)).height = 0
    map:GetGround(map:GetIndex(map.width, 1)).height = 0
    local path
    s = socket.gettime()
    -- for i = 1, 90 do
        path = SearchPath(map, map:GetGround(map:GetIndex(1, map.width)), map:GetGround(map:GetIndex(map.height, 1)))
    -- end
    local s = socket.gettime() - s
    local function IsIn(index)
        for i, v in ipairs(path or {}) do
            if v == index then
                return i
            end
        end
        return false
    end
    for i = 1, map.width do
        for j = 1, map.height do
            local index = map:GetIndex(i, j)
            local i = IsIn(index)
            if i then
                table.insert(m, string.format('[%d]', i%10))
            else
                local g = map:GetGround(index)
                -- table.insert(m, string.format('[%d]',index))
                table.insert(m, (g.height ~= 0 and '[+]' or ((g.x == map.width and g.y == 1) and '[E]' or ((g.x == 1 and g.y == map.height) and '[S]' or '[ ]'))))
            end
        end
        table.insert(m, '\n')
    end
    print(table.concat(m, ''))
    print('time', s)
    print('index', iiii)
    iiii = iiii + 1
    -- local a = {1, nil, 2, nil, 3, nil}
    -- print(1 / 0, - 1 / 0, math.sqrt(-1))
    -- print(#a)
    -- t:Tick()
    -- h(2)
    -- print(json.encode(t.__props__))
    -- local m = {}
    -- for i = 1, 10000 do
    --     table.insert(m, math.random(1, 90))
    -- end
    -- local s = socket.gettime()
    -- for i = 1, 90 do
    --     local c = {}
    --     -- for i, v in ipairs(m) do
    --     --     c[i] = v
    --     -- end
    --     table.sort(m, function(a, b)
    --         return a < b
    --     end)
    -- end
    -- print(socket.gettime() - s)
    -- s = socket.gettime()
    -- for i = 1, 90 do
    --     local b = BinHeap.New():Init(nil, m)
    -- end
    -- print(socket.gettime() - s)
    -- heap:Remove(1)
    -- heap:Add(math.random(1, 90))
    -- print(table.concat(heap._vec, ' '))
    Sleep(0)
end