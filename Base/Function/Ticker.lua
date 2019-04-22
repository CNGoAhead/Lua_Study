require('socket')

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
}

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

local Ticker = {
    __run__ = false,
    __now__ = 0,
    __time__ = 0,
    __min_diff__ = 0.01,
    __timer__ = {},
    __tick__ = nil,
    __max_group_id__ = 10,
    __group_diff__ = 0.1,
    __cur_group_id__ = 0,
    __tag_timer__ = {},
    __group_count__ = 0,
    __max_group_count = math.floor(math.pow(2, 32)),
    __can_skip__ = false
}

function Ticker.New(mindiff, maxgroup, canskip)
    local instance = {}
    setmetatable(instance, {__index = Ticker})
    instance.__min_diff__ = mindiff or 0.01
    instance.__max_group_id__ = maxgroup or 10
    instance.__can_skip__ = canskip or false
    instance.__group_diff__ = instance.__min_diff__ * instance.__max_group_id__
    for _ = 1, instance.__max_group_id__ do
        table.insert(instance.__timer__, {})
    end
    return instance
end

function Ticker:Begin()
    self.__run__ = true
    self.__time__ = 0
    self.__now__ = socket.gettime()
    self.__cur_group_id__ = 0
end

function Ticker:Stop()
    self.__run__ = false
    self:Clear()
end

function Ticker:Call()
    if self.__cur_group_id__ == 0 then
        return
    end
    local tree = self.__timer__[self.__cur_group_id__]
    local groups = tree[self.__group_count__]
    if groups then
        for diff, v in pairs(groups.TimerGroups) do
            local head = v.Head
            local last
            local df = head and (self.__can_skip__ and self.__now__ - head.LastCall or diff)
            while head do
                last = head
                head = last.Next
                last.Call(df)
                last.LastCall = self.__now__
            end
            if self.__can_skip__ and v.Head then
                self:SetTimerList(v.Head, math.ceil(df / diff) * diff)
            elseif v.Head then
                self:SetTimerList(v.Head, diff)
            end
        end
        tree[self.__group_count__] = nil
    end
end

function Ticker:Clear()
    self.__now__ = 0
    self.__time__ = 0
    for i, _ in pairs(self.__timer__) do
        self.__timer__[i] = {}
    end
    self.__tick__ = nil
    self.__cur_group_id__ = 0
    self.__tag_timer__ = {}
end

function Ticker:TickCall(diff)
    local tick = self.__tick__
    local last
    while tick do
        last = tick
        tick = tick.Next
        last.Call(diff)
    end
end

function Ticker:Tick(diff)
    if not self.__run__ then
        return
    end
    local now = socket.gettime()
    diff = diff or now - self.__now__
    self.__now__ = now
    self.__time__ = self.__time__ + diff
    self:TickCall(diff)
    local group = math.min(math.floor(self.__time__ / self.__min_diff__), self.__max_group_id__)
    local loop = group
    while loop > 0 do
        self:Call()
        if self.__cur_group_id__ == self.__max_group_id__ then
            self.__group_count__ = self.__group_count__ + 1
            self:GroupCountConstraint(self.__group_count__ + 1)
        end
        self.__cur_group_id__ = self:NextGroupId(self.__cur_group_id__, 1)
        loop = loop - 1
    end
    self.__time__ = self.__time__ - group * self.__min_diff__
end

function Ticker:GetTickGroup(groupId, groupCount)
    local groups = New(TickGroup)
    groups.GroupId = groupId
    groups.GroupCount = groupCount
    if not self.__timer__[groupId][groupCount] then
        self.__timer__[groupId][groupCount] = groups
    end
    return self.__timer__[groupId][groupCount]
end

function Ticker:GetTimerGroup(groupId, groupCount, diff)
    local groups = self:GetTickGroup(groupId, groupCount)
    if groups.TimerGroups[diff] then
        return groups.TimerGroups[diff]
    end
    groups.TimerGroups[diff] = New(TimerGroup)
    local group = groups.TimerGroups[diff]
    group.Diff = diff
    group.Group = groups
    return group
end

function Ticker:ConstraintDiff(diff)
    local scale = 1 / self.__min_diff__
    return math.floor(diff * scale + 0.5) / scale
end

function Ticker:GetGroupId(diff)
    return math.floor(diff / self.__min_diff__) % self.__max_group_id__
end

function Ticker:GetGroupCount(diff)
    return math.floor(diff / self.__group_diff__)
end

function Ticker:NextGroupId(id, diff)
    id = id + diff
    local groupDiff = 0
    while id > self.__max_group_id__ do
        id = id - self.__max_group_id__
        groupDiff = groupDiff + 1
    end
    while id < 1 do
        id = id + self.__max_group_id__
        groupDiff = groupDiff - 1
    end
    return id, groupDiff
end

function Ticker:AddToTag(tag, timer)
    tag = tag or '__Default__'
    self.__tag_timer__[tag] = self.__tag_timer__[tag] or {}
    table.insert(self.__tag_timer__[tag], timer)
end

function Ticker:GroupCountConstraint(count)
    return count % self.__max_group_count
end

function Ticker:SetTimerList(timer, diff)
    local groupId, groupDiff = self:NextGroupId(self.__cur_group_id__, self:GetGroupId(diff))
    local group = self:GetTimerGroup(groupId, self:GroupCountConstraint(self.__group_count__ + self:GetGroupCount(diff) + groupDiff), diff)
    if group.Tail then
        timer.Last = group.Tail
        timer.Last.Next = timer
        group.Tail = timer
    else
        group.Head = timer
        group.Tail = timer
    end
    timer.Group = group
    return timer
end

function Ticker:SetTimer(call, diff, tag)
    if not self.__run__ then
        self:Begin()
    end
    diff = diff or 0
    if diff < self.__min_diff__ then
        return self:SetTick(call, tag)
    end
    diff = self:ConstraintDiff(diff)
    local timer = New(Timer)
    timer.Call = call
    timer.LastCall = self.__now__ + self.__min_diff__ - self.__time__
    self:AddToTag(tag, timer)
    self:SetTimerList(timer, diff)
    return timer
end

function Ticker:SetTick(call, tag)
    if not self.__run__ then
        self:Begin()
    end
    local timer = New(Timer)
    timer.Call = call
    timer.LastCall = self.__now__
    self:AddToTag(tag, timer)
    if self.__tick__ then
        self.__tick__.Last = timer
        timer.Next = self.__tick__
    end
    self.__tick__ = timer
    return timer
end

function Ticker:RemoveTimer(timer)
    if self.__tick__ == timer then
        self.__tick__ = timer.Next
        self.__tick__.Last = nil
        timer.Next = nil
    else
        if timer.Last then
            timer.Last.Next = timer.Next
        elseif timer.Group then
            timer.Group.Head = timer.Next
        end
        if timer.Next then
            timer.Next.Last = timer.Last
        elseif timer.Group then
            timer.Group.Tail = timer.Last
        end
    end
end

function Ticker:RemoveTimerByTag(tag)
    for _, v in pairs(self.__tag_timer__[tag] or {}) do
        self:RemoveTimer(v)
    end
end

return function()
    return Ticker
end