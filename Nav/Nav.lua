local Nav = {}

local alien = require('alien')

local NavDll = alien.load('Nav/Nav.Dll')

-- Nav * Create()
local Create = NavDll.Create
Create:types('pointer')

-- void Delete(Nav * nav)
local Delete = NavDll.Delete
Delete:types('void', 'pointer')

-- void Init(Nav * nav, int w, int h)
local Init = NavDll.Init
Init:types('void', 'pointer', 'int', 'int')

-- @heights [x, y, h, x, y, h, ...]
-- @len = heights.size() / 3
-- void UpdateHeight(Nav * nav, int * heights, int len)
local UpdateHeight = NavDll.UpdateHeight
UpdateHeight:types('void', 'pointer', 'pointer', 'int')

-- @heights [x, y, h, x, y, h, ...]
-- @len = heights.size() / 3
-- void AddHeight(Nav * nav, int * heights, int len)
local AddHeight = NavDll.AddHeight
AddHeight:types('void', 'pointer', 'pointer', 'int')

-- @heights [x, y, h, x, y, h, ...]
-- @len = heights.size() / 3
-- void SubHeight(Nav * nav, int * heights, int len)
local SubHeight = NavDll.SubHeight
SubHeight:types('void', 'pointer', 'pointer', 'int')

-- @flags [x, y, h, x, y, h, ...]
-- @len = flags.size() / 3
-- void UpdateFlag(Nav * nav, int * flags, int len)
local UpdateFlag = NavDll.UpdateFlag
UpdateFlag:types('void', 'pointer', 'pointer', 'int')

-- @flags [x, y, h, x, y, h, ...]
-- @len = flags.size() / 3
-- void AddFlag(Nav * nav, int * flags, int len)
local AddFlag = NavDll.AddFlag
AddFlag:types('void', 'pointer', 'pointer', 'int')

-- @flags [x, y, h, x, y, h, ...]
-- @len = flags.size() / 3
-- void AddFlag(Nav * nav, int * flags, int len)
local SubFlag = NavDll.SubFlag
SubFlag:types('void', 'pointer', 'pointer', 'int')

-- @path out 返回路径或者继续寻路的ID
-- @return path的长度 如果为1则代表起点和终点是同一个，或者 在规定时间内没完成寻路，path[1]为继续寻路的ID；如果长度为0代表寻路失败无法到达
-- int Search(Nav * nav, int * path, int sx, int sy, int ex, int ey, int dps, int speed, int duration)
local Search = NavDll.Search
Search:types('int', 'pointer', 'pointer', 'int', 'int', 'int', 'int', 'int', 'int', 'int')

-- @path out 同上
-- @return 同上
-- int FlagSearch(Nav * nav, int * path, int sx, int sy, short flag, int dps, int speed, int duration)
local FlagSearch = NavDll.FlagSearch
FlagSearch:types('int', 'pointer', 'pointer', 'int', 'int', 'short', 'int', 'int', 'int')

-- @path out 同上
-- @ends [x, y, x, y, ...]
-- @len = ends.size() / 3
-- @return 同上
-- int MultiSearch(Nav * nav, int * path, int sx, int sy, int * ends, int len, int dps, int speed, int duration)
local MultiSearch = NavDll.MultiSearch
MultiSearch:types('int', 'pointer', 'pointer', 'int', 'int', 'pointer', 'int', 'int', 'int', 'int')

-- @path out 同上
-- resumeId 继续寻路的ID
-- @return 同上
-- int ResumeSearch(Nav * nav, int * path, int resumeId, int duration)
local ResumeSearch = NavDll.ResumeSearch
ResumeSearch:types('int', 'pointer', 'pointer', 'int', 'int')

--@x 起点是0
--@y 起点是0
function Nav.GetIndex(nav, x, y)
    return y * nav.w + x;
end

function Nav.GetX(nav, k)
    return k % nav.w
end

function Nav.GetY(nav, k)
    return math.floor(k / nav.w)
end

function Nav.Create()
    local instance = {pointer = Create(), w = 0, h = 0}
    setmetatable(instance, {__index = Nav})
    return instance
end

function Nav.Delete(nav)
    return Delete(nav.pointer)
end

function Nav.Init(nav, w, h)
    nav.w = w
    nav.h = h
    return Init(nav.pointer, w, h)
end

--@heights {(int)AStarKey = (int)height, ...}
function Nav.UpdateHeight(nav, heights)
    local array = {}
    local len = 0
    for k, v in pairs(heights) do
        table.insert(array, nav:GetX(k))
        table.insert(array, nav:GetY(k))
        table.insert(array, v)
        len = len + 1
    end
    array = alien.array('int', array)
    UpdateHeight(nav.pointer, array.buffer, len)
end

function Nav.AddHeight(nav, heights)
    local array = {}
    local len = 0
    for k, v in pairs(heights) do
        table.insert(array, nav:GetX(k))
        table.insert(array, nav:GetY(k))
        table.insert(array, v)
        len = len + 1
    end
    array = alien.array('int', array)
    AddHeight(nav.pointer, array.buffer, len)
end

function Nav.SubHeight(nav, heights)
    local array = {}
    local len = 0
    for k, v in pairs(heights) do
        table.insert(array, nav:GetX(k))
        table.insert(array, nav:GetY(k))
        table.insert(array, v)
        len = len + 1
    end
    array = alien.array('int', array)
    SubHeight(nav.pointer, array.buffer, len)
end

--@flags {(int)AStarKey = (int)flag, ...}
function Nav.UpdateFlag(nav, flags)
    local array = {}
    local len = 0
    for k, v in pairs(flags) do
        table.insert(array, nav:GetX(k))
        table.insert(array, nav:GetY(k))
        table.insert(array, v)
        len = len + 1
    end
    array = alien.array('int', array)
    UpdateFlag(nav.pointer, array.buffer, len)
end

--@flags {(int)AStarKey = (int)flag, ...}
function Nav.AddFlag(nav, flags)
    local array = {}
    local len = 0
    for k, v in pairs(flags) do
        table.insert(array, nav:GetX(k))
        table.insert(array, nav:GetY(k))
        table.insert(array, v)
        len = len + 1
    end
    array = alien.array('int', array)
    AddFlag(nav.pointer, array.buffer, len)
end

--@flags {(int)AStarKey = (int)flag, ...}
function Nav.SubFlag(nav, flags)
    local array = {}
    local len = 0
    for k, v in pairs(flags) do
        table.insert(array, nav:GetX(k))
        table.insert(array, nav:GetY(k))
        table.insert(array, v)
        len = len + 1
    end
    array = alien.array('int', array)
    SubFlag(nav.pointer, array.buffer, len)
end

local function ReturnPath(nav, path, len)
    if len > 1 then
        local ret = {}
        for i = 1, len do
            ret[i] = {x = nav:GetX(path[i]), y = nav:GetY(path[i])}
        end
        return ret      --路径[{x,y}, ...]
    elseif len == 1 then
        return path[1]  --继续寻路的ID
    else
        return -1   --寻路失败
    end
end

function Nav.Search(nav, sx, sy, ex, ey, dps, speed, duration)
    duration = duration or -1
    local path = alien.array('int', nav.w * nav.h)
    local len = Search(nav.pointer, path.buffer, sx, sy, ex, ey, dps, speed, duration)
    return ReturnPath(nav, path, len)
end

function Nav.FlagSearch(nav, sx, sy, flag, dps, speed, duration)
    duration = duration or -1
    local path = alien.array('int', nav.w * nav.h)
    local len = FlagSearch(nav.pointer, path.buffer, sx, sy, flag, dps, speed, duration)
    return ReturnPath(nav, path, len)
end

--@ends [{x, y} or [x, y], ...]
function Nav.MultiSearch(nav, sx, sy, ends, dps, speed, duration)
    duration = duration or -1
    local es = alien.array('int', #ends * 2)
    for i = 1, #ends do
        es[2 * i - 1] = ends[i].x or ends[i][1]
        es[2 * i] = ends[i].y or ends[i][2]
    end
    local path = alien.array('int', nav.w * nav.h)
    local len = FlagSearch(nav.pointer, path.buffer, sx, sy, es.buffer, #ends, dps, speed, duration)
    return ReturnPath(nav, path, len)
end

function Nav.ResumeSearch(nav, id, duration)
    duration = duration or -1
    local path = alien.array('int', nav.w * nav.h)
    local len = ResumeSearch(nav.pointer, path.buffer, id, duration)
    return ReturnPath(nav, path, len)
end

local Bit = require('bit')

local NavSys = {
    __height_cmd__ = {},
    __flag_cmd__ = {},
    __search_cmd__ = {},
    __result_cache__ = {}
}

NavSys.ENavCmd = {
    ['Search'] = 1,
    ['FlagSearch'] = 2,
    ['MultiSearch'] = 3,
    ['ResumeSearch'] = 4,

    ['UpdateHeight'] = 5,
    ['AddHeight'] = 6,
    ['SubHeight'] = 7,
    ['UpdateFlag'] = 8,
    ['AddFlag'] = 9,
    ['SubFlag'] = 10,
}

local CmdFunc = {
    'Search',
    'FlagSearch',
    'MultiSearch',
    'ResumeSearch',
    'UpdateHeight',
    'UpdateHeight',
    'UpdateHeight',
    'UpdateFlag',
    'UpdateFlag',
    'UpdateFlag',
}

local function Key(a, params)
    local k = ''
    for _, v in ipairs(params) do
        k = k .. tostring(a[v])
    end
    return k
end

local function Equal(a, b, params)
    if type(a) == 'table' and type(b) == 'table' then
        if params then
            for _, v in ipairs(params) do
                if not Equal(a[v], b[v]) then
                    return false
                end
            end
            return true
        else
            for k, v in pairs(a) do
                if not Equal(b[k], v) then
                    return false
                end
            end
            for k, v in pairs(b) do
                if not Equal(a[k], v) then
                    return false
                end
            end
            return true
        end
    else
        return a == b
    end
end

local MergeKey = {
    [NavSys.ENavCmd.Search] = function(a)
        return Key(a, {1, 2, 3, 4, 5, 8})
    end,
    [NavSys.ENavCmd.FlagSearch] = function(a)
        return Key(a, {1, 2, 3, 4, 7})
    end,
    [NavSys.ENavCmd.MultiSearch] = function(a)
        return Key(a, {1, 2, 3, 4, 7})
    end,
    [NavSys.ENavCmd.ResumeSearch] = function(a)
        return Key(a, {1, 2, 3})
    end,
    [NavSys.ENavCmd.UpdateHeight] = function(a, b)
        return Key(a, {1})
    end,
    [NavSys.ENavCmd.AddHeight] = function(a, b)
        return Key(a, {1})
    end,
    [NavSys.ENavCmd.SubHeight] = function(a, b)
        return Key(a, {1})
    end,
    [NavSys.ENavCmd.UpdateFlag] = function(a, b)
        return Equal(a, {1})
    end,
    [NavSys.ENavCmd.AddFlag] = function(a, b)
        return Key(a, {1})
    end,
    [NavSys.ENavCmd.SubFlag] = function(a, b)
        return Key(a, {1})
    end,
}

local MergeCmd = {
    [NavSys.ENavCmd.Search] = function(a, b)
        if Equal(a, b, {1, 2, 3, 4, 5, 8}) then
            a[6] = a[6] + b[6]
            a[7] = math.min(a[7], b[7])
            return true
        end
        return false
    end,
    [NavSys.ENavCmd.FlagSearch] = function(a, b)
        if Equal(a, b, {1, 2, 3, 4, 7}) then
            a[5] = a[5] + b[5]
            a[6] = math.min(a[6], b[6])
            return true
        end
        return false
    end,
    [NavSys.ENavCmd.MultiSearch] = function(a, b)
        if Equal(a, b, {1, 2, 3, 4, 7}) then
            a[5] = a[5] + b[5]
            a[6] = math.min(a[6], b[6])
            return true
        end
        return false
    end,
    [NavSys.ENavCmd.ResumeSearch] = function(a, b)
        return Equal(a, b, {1, 2, 3})
    end,
    [NavSys.ENavCmd.UpdateHeight] = function(a, b)
        if Equal(a, b, {1}) then
            for k, v in pairs(b[2]) do
                a[2][k] = v
            end
            return true
        end
        return false
    end,
    [NavSys.ENavCmd.AddHeight] = function(a, b)
    if Equal(a, b, {1}) then
            for k, v in pairs(b[2]) do
                a[2][k] = (a[2][k] or 0) + v
            end
            return true
        end
        return false
    end,
    [NavSys.ENavCmd.SubHeight] = function(a, b)
        if Equal(a, b, {1}) then
            for k, v in pairs(b[2]) do
                a[2][k] = v
            end
            return true
        end
        return false
    end,
    [NavSys.ENavCmd.UpdateFlag] = function(a, b)
        if Equal(a, b, {1}) then
            for k, v in pairs(b[2]) do
                a[2][k] = v
            end
            return true
        end
        return false
    end,
    [NavSys.ENavCmd.AddFlag] = function(a, b)
    if Equal(a, b, {1}) then
            for k, v in pairs(b[2]) do
                a[2][k] = Bit.bor((a[2][k] or 0), v)
            end
            return true
        end
        return false
    end,
    [NavSys.ENavCmd.SubFlag] = function(a, b)
        if Equal(a, b, {1}) then
            for k, v in pairs(b[2]) do
                a[2][k] = Bit.band((a[2][k] or 0), Bit.bnot(v))
            end
            return true
        end
        return false
    end,
}

function NavSys.AddCmd(ecmd, ...)
    if ecmd <= NavSys.ENavCmd.ResumeSearch then
        local cmd = {...}
        NavSys.__search_cmd__[CmdFunc[ecmd]] = NavSys.__search_cmd__[CmdFunc[ecmd]] or {}
        local key = MergeKey[ecmd](cmd)
        local ocmd = NavSys.__search_cmd__[CmdFunc[ecmd]][key]
        if ocmd and MergeCmd[ecmd](ocmd, cmd) then
            return ocmd.resultID
        end
        NavSys.__search_cmd__[CmdFunc[ecmd]][key] = cmd
        cmd.resultID = #NavSys.__result_cache__ + 1
        NavSys.__result_cache__[cmd.resultID] = false
        return cmd.resultID
    elseif ecmd >= NavSys.ENavCmd.UpdateHeight and ecmd <= NavSys.ENavCmd.SubHeight then
        local cmd = {...}
        NavSys.__height_cmd__[CmdFunc[ecmd]] = NavSys.__height_cmd__[CmdFunc[ecmd]] or {}
        local key = MergeKey[ecmd](cmd)
        local ocmd = NavSys.__height_cmd__[CmdFunc[ecmd]][key]
        if ocmd and MergeCmd[ecmd](ocmd, cmd) then
            return
        end
        NavSys.__height_cmd__[CmdFunc[ecmd]][key] = cmd
        return
    elseif ecmd >= NavSys.ENavCmd.UpdateFlag and ecmd <= NavSys.ENavCmd.SubFlag then
        local cmd = {...}
        local key = MergeKey[ecmd](cmd)
        local ocmd = NavSys.__flag_cmd__[CmdFunc[ecmd]][key]
        if ocmd and MergeCmd[ecmd](ocmd, cmd) then
            return
        end
        NavSys.__flag_cmd__[CmdFunc[ecmd]][key] = cmd
        return
    end
end

function NavSys.GetPath(resultId)
    return NavSys.__result_cache__[resultId]
end

function NavSys.Tick()
    for _, v in pairs(NavSys.__height_cmd__) do
        for k, p in pairs(v) do
            NavSys[k](p)
        end
    end
    for _, v in pairs(NavSys.__flag_cmd__) do
        for k, p in pairs(v) do
            NavSys[k](p)
        end
    end
    for k, v in pairs(NavSys.__search_cmd__) do
        for _, p in pairs(v) do
            NavSys[k](p)
        end
    end
    NavSys.__height_cmd__ = {}
    NavSys.__search_cmd__ = {}
    NavSys.__flag_cmd__ = {}
end

function NavSys.Search(params)
    local nav, sx, sy, ex, ey, dps, speed, duration = params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8]
    local path = nav:Search(sx, sy, ex, ey, dps, speed, duration)
    NavSys.__result_cache__[params.resultID] = path
end

function NavSys.FlagSearch(params)
    local nav, sx, sy, flag, dps, speed, duration = params[1], params[2], params[3], params[4], params[5], params[6], params[7]
    local path = nav:FlagSearch(sx, sy, flag, dps, speed, duration)
    NavSys.__result_cache__[params.resultID] = path
end

function NavSys.MultiSearch(params)
    local nav, sx, sy, ends, dps, speed, duration = params[1], params[2], params[3], params[4], params[5], params[6], params[7]
    local path = nav:MultiSearch(sx, sy, ends, dps, speed, duration)
    NavSys.__result_cache__[params.resultID] = path
end

function NavSys.ResumeSearch(params)
    local nav, id, duration = params[1], params[2], params[3]
    local path = nav:ResumeSearch(id, duration)
    NavSys.__result_cache__[params.resultID] = path
end

function NavSys.UpdateHeight(params)
    local nav, heights = params[1], params[2]
    nav:UpdateHeight(heights)
end

function NavSys.UpdateFlag(params)
    local nav, flags = params[1], params[2]
    nav:UpdateFlag(flags)
end

return function()
    return Nav, NavSys
end