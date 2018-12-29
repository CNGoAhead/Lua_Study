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

while 1 do
    local a = {1, nil, 2, nil, 3, nil}
    print(1 / 0, - 1 / 0, math.sqrt(-1))
    print(#a)
    t:Tick()
    h(2)
    print(json.encode(t.__props__))
    Sleep(5)
end