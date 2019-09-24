local socket = require('socket')

local Look = require('Base2.Look')()

local tcp = socket.tcp()

tcp:settimeout(0)
tcp:connect('localhost', 8032)

local file = io.open('./Debug/CorTest.lua', 'r')

local data = file:read('*a')

while 1 do
    print(tcp:send(string.format('%010d', #data) .. data))
    socket.sleep(1)
end