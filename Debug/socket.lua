local __t__ = 0

local socket = {
    gettime = function()
        __t__ = __t__ + 0.01
        return __t__
    end
}

return socket