local socket = require('Debug.socket')

local __run__ = false
local __now__ = 0
local __time__ = 0
local __min_diff__ = 0.01
-- (0.00, 0.01], (0.01, 0.02], (0.02, 0.03], (0.03, 0.04], (0.04, 0.05], (0.05, 0.06], (0.06, 0.07], (0.07, 0.08], (0.08, 0.09], (0.09, 0.10]
local __timer__ = {}
-- 从大到小
local __wait__ = {}
local __tick__ = nil
local __max_group_id__ = 10
local __group_diff__ = __max_group_id__ * __min_diff__
local __cur_group_id__ = 0
local __tag_timer__ = {}

local __group_count__ = 0

local Timer = {
    Last = nil,
    Next = nil,
    Call = nil,
    LastCall = 0,
    Group = nil
}

local TimerGroup = {
    Head = nil,
    Tail = nil,
    Diff = 0,
    Group = nil,
}

local TickGroup = {
    GroupId = 1,
    GroupCount = 0,
    TimerGroups = {},   --k=diff, v=TimeGroup
    Parent = nil,
    Left = nil,         -- <
    Right = nil,         -- >
}

local function ConstraintDiff(diff)
    local scale = 1 / __min_diff__
    return math.floor(diff * scale + 0.5) / scale
    -- return diff - diff % __min_diff__
end

local function New(Class)
    local Obj = {}
    for k, v in pairs(Class) do
        if type(v) == 'table' then
            Obj[k] = New(v)
        else
            Obj[k] = v
        end
    end
    return Obj
end

local function GetTickGroup(groupId, groupCount)
    local head = __timer__[groupId]
    local last
    if head then
        if head.GroupCount == groupCount then
            return head
        end
        while head.Parent and groupCount >= head.Parent.GroupCount do
            head = head.Parent
        end
        while head do
            last = head
            if groupCount > head.GroupCount then
                head = head.Right
            elseif groupCount < head.GroupCount then
                head = head.Left
            else
                return head
            end
        end
    end
    head = New(TickGroup)
    head.GroupId = groupId
    head.GroupCount = groupCount
    if last then
        head.Parent = last
        if last.GroupCount > head.GroupCount then
            last.Left = head
        else
            last.Right = head
        end
    end
    if not __timer__[groupId] or head.GroupCount < __timer__[groupId].GroupCount then
        __timer__[groupId] = head
    end
    -- if head.GroupCount > MAX_GROUP_COUNT then
    --     print('Clear')
    --     ClearCount(groupId)
    -- end
    return head
end

local function GetTimerGroup(groupId, groupCount, diff)
    local groups = GetTickGroup(groupId, groupCount)
    if groups.TimerGroups[diff] then
        return groups.TimerGroups[diff]
    end
    groups.TimerGroups[diff] = New(TimerGroup)
    local group = groups.TimerGroups[diff]
    group.Diff = diff
    group.Group = groups
    return group
end


local function GetGroupId(diff)
    return math.ceil((diff * (1 / __min_diff__)) % __max_group_id__)
    -- return math.ceil((diff % __group_diff__) / __min_diff__)
end

local function GetGroupCount(diff)
    return math.floor(diff / __group_diff__)
end

local function NextGroupId(id, diff)
    id = id + diff
    local groupDiff = 0
    while id > __max_group_id__ do
        id = id - __max_group_id__
        groupDiff = groupDiff + 1
    end
    while id < 1 do
        id = id + __max_group_id__
        groupDiff = groupDiff - 1
    end
    return id, groupDiff
end

local function AddToTag(tag, timer)
    tag = tag or '__Default__'
    __tag_timer__[tag] = __tag_timer__[tag] or {}
    table.insert(__tag_timer__[tag], timer)
end

local function SetTimer(timer, diff)
    local groupId, groupDiff = NextGroupId(__cur_group_id__, GetGroupId(diff))
    local group = GetTimerGroup(groupId, __group_count__ + GetGroupCount(diff) + groupDiff, diff)
    if group.Tail then
        timer.Last = group.Tail
        timer.Last.Next = timer
        group.Tail = timer
    else
        group.Head = timer
        group.Tail = timer
    end
    timer.Group = group
end


local function AddTick(call, tag)
    local timer = New(Timer)
    timer.Call = call
    timer.LastCall = __now__
    AddToTag(tag, timer)
    if __tick__ then
        __tick__.Last = timer
        timer.Next = __tick__
    end
    __tick__ = timer
    return timer
end

local function AddTimer(call, tag, diff)
    diff = diff or 0
    diff = ConstraintDiff(diff)
    if diff <= __min_diff__ then
        return AddTick(call, tag)
    end
    local timer = New(Timer)
    timer.Call = call
    timer.LastCall = __now__
    AddToTag(tag, timer)
    SetTimer(timer, diff)
    return timer
end

local function RemoveTimer(timer)
    if timer.Group then
        if timer.Group.Head == timer then
            timer.Group.Head = timer.Next
        end
        if timer.Group.Tail == timer then
            timer.Group.Tail = timer.Last
        end
    elseif __tick__ == timer then
        __tick__ = timer.Next
    end
    if timer.Last then
        timer.Last.Next = timer.Next
    end
    if timer.Next then
        timer.Next.Last = timer.Last
    end
end

local function RemoveTimerByTag(tag)
    for _, v in pairs(__tag_timer__[tag] or {}) do
        RemoveTimer(v)
    end
end

local function RemoveTickGroup(groups)
    local ret
    if groups.Right then
        ret = groups.Right
        if groups.Parent then
            groups.Parent.Left = ret
            ret.Parent = groups.Parent
        end
        while ret.Left do
            ret = ret.Left
        end
    else
        ret = groups.Parent
        groups.Parent = nil
        if ret then
            ret.Left = nil
        end
    end
    return ret
end

local function Call()
    local groups = __timer__[__cur_group_id__]
    if groups and groups.GroupCount == __group_count__ then
        for diff, v in pairs(groups.TimerGroups) do
            local head = v.Head
            local df = head and __now__ - head.LastCall or 0
            while head do
                head.Call(df)
                head.LastCall = __now__
                head = head.Next
            end
            SetTimer(v.Head, diff)
        end
        local next = RemoveTickGroup(groups)
        __timer__[__cur_group_id__] = next
    end
end

local function Clear()
    __now__ = 0
    __time__ = 0
    __min_diff__ = 0.01
    __timer__ = {}
    __wait__ = {}
    __tick__ = nil
    __max_group_id__ = #__timer__
    __group_diff__ = __max_group_id__ * __min_diff__
    __cur_group_id__ = 0
    __tag_timer__ = {}
end

local function TickCall(diff)
    local tick = __tick__
    while tick do
        tick.Call(diff)
        tick = tick.Next
    end
end

local function Tick()
    if not __run__ then
        return
    end
    local now = socket.gettime()
    local diff = now - __now__
    __now__ = now
    __time__ = __time__ + diff
    TickCall(diff)
    local group = math.floor(__time__ / __min_diff__)
    local loop = group
    while loop > 0 do
        Call()
        if __cur_group_id__ == __max_group_id__ then
            __group_count__ = __group_count__ + 1
        end
        __cur_group_id__ = NextGroupId(__cur_group_id__, 1)
        loop = loop - 1
    end
    __time__ = __time__ - group * __min_diff__
end

local function Begin()
    __run__ = true
    __time__ = 0
    __now__ = socket.gettime()
    __cur_group_id__ = 0
end

local function Pause()
    __run__ = false
end

local function Resume()
    __run__ = true
    Tick(socket.gettime() - __now__)
end

local function Stop()
    __run__ = false
    Clear()
end

return function()
    return {
        Begin = Begin,
        Pause = Pause,
        Resume = Resume,
        Stop = Stop,
        Tick = Tick,
        AddTick = AddTimer,
        RemoveTick = RemoveTimerByTag
    }
end