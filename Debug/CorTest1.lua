-- require('Base.Init')
local socket = require('socket')


local Server = {
    Addr = '127.0.0.1',
    Port = 9468,
}

function Server.New()
    local server, err, code
    local function check(p)
        if not p then
            print(err)
            return err
        end
    end
    server, err = socket.tcp()
    check(server)
    code, err = server:setoption("reuseaddr", true)
    check(code)
    code, err = server:setoption("keepalive", true)
    check(code)
    code, err = server:bind('localhost', Server.Port)
    check(code)
    code, err = server:listen(1000)
    check(code)
    print(server:getsockname())

    local clients = {}

    return coroutine.create(
        function()
            while true do
                print('beg accept')
                local client = server:accept()
                print('end accept')
                if client then
                    client:settimeout(0)
                    while true do
                        print(client:receive())
                    end
                end
                coroutine.yield()
            end
        end
    ),
    coroutine.create(
        function()
            while true do
                for _, v in ipairs(clients) do
                    local rec, sed, stat = socket.select({v}, nil, 1)
                    print(rec, sed, stat)
                    if #rec > 0 then
                        print(#rec, #sed, stat)
                        print(v:getstats())
                        print('beg s recv')
                        print(v:receive(2^10))
                        print('end s recv')
                        print('beg s send')
                        print(v:send('123'))
                        print('end s end')
                    end
                end
            end
        end
    )
end

local function main()
    local p1, p2 = Server.New()
    coroutine.resume(p1)
    -- coroutine.resume(p2)
    while true do
    end
end

main()