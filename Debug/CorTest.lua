-- require('Base.Init')
local socket = require('socket')

local Client = {
    Addr = '0.0.0.0',
    Port = 9468,
}

function Client.New()
    local client, err, code
    local function check(p)
        if not p then
            print(err)
            return err
        end
    end
    print('beg c connect')
    client, err = socket.connect('localhost', Client.Port)
    print('end c connect')
    client:settimeout(0)
    return coroutine.create(
        function()
            while true do
                print('beg c send')
                print(client:send('123'))
                print('end c send')
                coroutine.yield()
                print('beg c recv')
                print(client:receive(2^10))
                print('end c recv')
                coroutine.yield()
            end
        end
    )
end

local function main()
    local p3 = Client.New()
    while true do
        coroutine.resume(p3)
    end
end

main()