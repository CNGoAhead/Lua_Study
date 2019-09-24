local socket = require('socket')

local Look = require('Base2.Look')()

local tcp = socket.tcp()

tcp:bind('localhost', 8032)

local C_MAX_LEN = 4
local C_MAX = 256^C_MAX_LEN - 1

local function S(n)
    assert(n <= C_MAX)
    local r = ''
    while n > 0 do
        r = r .. string.char(n % 256)
        n = math.floor(n / 256)
    end
    while string.len(r) < C_MAX_LEN do
        r = r .. '\0'
    end
    return r
end

local n = S(256^4)
print(string.len(n))
local num = 0
for i = 1, #n do
    num = num + string.byte(n, i) * (256^(i - 1))
end
print(num)

if 1 then
    return
end

tcp:setoption("reuseaddr", true)
tcp:setoption('keepalive', true)

tcp:listen(10)

local server = {tcp}
local sc = {}

local C_HEAD_LEN = 10

local rec, sed, stat
while 1 do
    rec, sed, stat = socket.select(server, nil, 0.1)
    if #rec > 0 then
        for _, v in ipairs(rec) do
            local c = v:accept()
            c:settimeout(0)
            table.insert(sc, c)
        end
    end
    rec, sed, stat = socket.select(sc, nil, 0.1)
    local data = ''
    if #rec > 0 then
        for _, v in ipairs(rec) do
            while #data ~= C_HEAD_LEN do
                local data1, _, data2 = v:receive(C_HEAD_LEN - #data)
                data = data .. (data1 or data2)
            end
            local len = tonumber(data)
            data = ''
            while #data ~= len do
                local data1, _, data2 = v:receive(len - #data)
                data = data .. (data1 or data2)
            end
            print(data)
        end
    end
    socket.sleep(10)
end