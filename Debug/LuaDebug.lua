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

local Test = Class('Test', TickUp)

function Test:Test()
    Property(self,
        {
            name = 'value',
            default = -10,
            flag = 'rw',
            OnChange = function()
                print('on change', self:PropGet('value'))
            end,
            OnSet = function()
                print('on set ' .. self:PropGet('value'))
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
end

local p1 = 2
local p2 = 3
local p3 = 4
local p4 = 5

local t = Test.new()

require("socket")
function Sleep(n)
   socket.select(nil, nil, n)
end

while 1 do
    t:Tick()
    print(json.encode(t.__props__))
    Sleep(5)
end