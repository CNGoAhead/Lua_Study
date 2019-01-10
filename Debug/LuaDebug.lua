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
            default = -10,
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

local t = Test.new()

function a(b, c, d)
    print(b, c, d)
end

local h = Handler(a, nil, 1)

require("socket")
function Sleep(n)
   socket.select(nil, nil, n)
end

local function decodeSeasonId(id)
    local mouth = id % 100
    local year = (id - mouth) / 100
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

    --赛季ID = 年 * 100 + 月
    return year * 100 + month
end

local function getMouthlyRankEndTime()
    local y, m = decodeSeasonId(getSeasonId())
    return os.time({year = y, month = m, day = 1, hour = 0, min = 0, sec = 0})
end

while 1 do
    for i = 1, 1000000 do
        string.find("123123132526243563512341412", '.*2.*2.*2.*')
    end
    print('end')
    -- local a = {1, nil, 2, nil, 3, nil}
    -- print(1 / 0, - 1 / 0, math.sqrt(-1))
    -- print(#a)
    -- t:Tick()
    -- h(2)
    -- print(json.encode(t.__props__))
    Sleep(5)
end