local Cron = {}

local INT_MAX = 2^31 - 1

local ExpDefine = {
    {Type = 'sec', Range = {0, 59}, Diff = 1},
    {Type = 'min', Range = {0, 59}, Diff = 1},
    {Type = 'hour', Range = {0, 23}, Diff = 1},
    {Type = 'day', Range = {1, 31}, Diff = 1},
    {Type = 'month', Range = {1, 12}, Diff = 1},
    {Type = 'wday', Range = {1, 7}, Diff = 1},
    {Type = 'year', Range = {0, INT_MAX}, Diff = 1},
}

local function split(text, sep)
    text = tostring(text)
    sep = tostring(sep)
    if sep == '' then return {text} end
    local strPos = {0}
    local curPos = 1
    local function AddPos(str)
        local s, e = string.find(text, str, curPos)
        if s and e then
            table.insert(strPos, s - 1)
            table.insert(strPos, e + 1)
            curPos = e + 1
        end
    end
    string.gsub(text, sep, AddPos)
    table.insert(strPos, -1)
    local result = {}
    for k = 1, #strPos, 2 do
        local v = strPos[k]
        if strPos[k + 1] then
            table.insert(result, string.sub(text, v, strPos[k + 1]))
        end
    end
    return result
end

local function clone(object)
    local ntbl = {}
    for k, v in pairs(object) do
        if type(v) == 'table' then
            ntbl[k] = clone(v)
        else
            ntbl[k] = v
        end
    end
    return ntbl
end

local function Step(min, now, max, diff)
    if min > max then
        min, max = max, min
    end
    if min > now then
        return min, 0
    end
    if now > max then
        return min, 1
    end
    now = min + math.ceil((now - min) / diff) * diff
    if now > max then
        return min, 1
    end
    return now, 0
end

local function NextAppoint(now, appoints)
    for _, v in ipairs(appoints) do
        if v >= now then
            return v, 0
        end
    end
    return appoints[1], 1
end

local function GetDiffTime(expression)
    return tonumber(string.match(expression, '/(%d+)'))
end

local function GetStartTime(expression)
    if string.find(expression, ',') then
        return
    elseif string.find(expression, '-') then
        return tonumber(string.match(expression, '(%d+)-'))
    elseif string.find(expression, '/') then
        return tonumber(string.match(expression, '(%d+)/'))
    else
        return tonumber(string.match(expression, '(%d+)'))
    end
end

local function GetEndTime(expression)
    if string.find(expression, ',') then
        return
    elseif string.find(expression, '-') then
        return tonumber(string.match(expression, '-(%d+)'))
    elseif string.find(expression, '/') then
        return
    else
        return tonumber(string.match(expression, '(%d+)'))
    end
end

local function GetAppointTime(expression)
    if string.find(expression, ',') then
        local times = split(expression, ',')
        for k, v in pairs(times) do
            times[k] = tonumber(v)
        end
        table.sort(times, function(a, b)
            return a < b
        end)
        return times
    end
end

local SEC_DAY = 86400

function Cron.next(expression, time)
    local timeZone = os.time(os.date('!*t', SEC_DAY)) - SEC_DAY
    local exps = split(expression, ' ')
    local expDefine = clone(ExpDefine)
    for i, v in pairs(exps) do
        expDefine[i].Range[1] = GetStartTime(v) or expDefine[i].Range[1]
        expDefine[i].Range[2] = GetEndTime(v) or expDefine[i].Range[2]
        expDefine[i].Diff = GetDiffTime(v) or expDefine[i].Diff
        expDefine[i].Appint = GetAppointTime(v)
    end

    local ttime = os.date('!*t', time)

    local function UpYear(dis)
        dis = dis or 0
        local newYear
        if expDefine[7].Appint then
            newYear = NextAppoint(ttime.year + dis * expDefine[7].Diff, expDefine[7].Appint)
        else
            newYear = Step(expDefine[7].Range[1], ttime.year + dis * expDefine[7].Diff, expDefine[7].Range[2], expDefine[7].Diff)
        end
        ttime = os.date('!*t', os.time({year = newYear, month = expDefine[5].Range[1], day = expDefine[4].Range[1], hour = expDefine[3].Range[1], min = expDefine[2].Range[1], sec = expDefine[1].Range[1]}) - timeZone)
    end

    local function UpMonth(dis)
        dis = dis or 0
        local newMonth, more
        if expDefine[5].Appint then
            newMonth, more = NextAppoint(ttime.month + dis * expDefine[5].Diff, expDefine[5].Appint)
        else
            newMonth, more = Step(expDefine[5].Range[1], ttime.month + dis * expDefine[5].Diff, expDefine[5].Range[2], expDefine[5].Diff)
        end
        if more ~= 0 then
            UpYear(more)
        else
            ttime = os.date('!*t', os.time({year = ttime.year, month = newMonth, day = expDefine[4].Range[1], hour = expDefine[3].Range[1], min = expDefine[2].Range[1], sec = expDefine[1].Range[1]}) - timeZone)
        end
    end

    local function UpDay(dis)
        dis = dis or 0
        local newDay, more
        if expDefine[4].Appint then
            newDay, more = NextAppoint(ttime.day + dis * expDefine[4].Diff, expDefine[4].Appint)
        else
            newDay, more = Step(expDefine[4].Range[1], ttime.day + dis * expDefine[4].Diff, expDefine[4].Range[2], expDefine[4].Diff)
        end
        if more ~= 0 then
            UpMonth(more)
        else
            ttime = os.date('!*t', os.time({year = ttime.year, month = ttime.month, day = newDay, hour = expDefine[3].Range[1], min = expDefine[2].Range[1], sec = expDefine[1].Range[1]}) - timeZone)
        end
    end

    local function UpWDay()
        local newWDay, more
        if expDefine[6].Appint then
            newWDay, more = NextAppoint(ttime.wday, expDefine[6].Appint)
        else
            newWDay, more = Step(expDefine[6].Range[1], ttime.wday, expDefine[6].Range[2], expDefine[6].Diff)
        end
        ttime.day = ttime.day + newWDay - ttime.wday
        if more ~= 0 then
            ttime.day = ttime.day + 7
        end
        UpDay()
    end

    local function UpHour(dis)
        dis = dis or 0
        local newHour, more
        if expDefine[3].Appint then
            newHour, more = NextAppoint(ttime.hour + dis * expDefine[3].Diff, expDefine[3].Appint)
        else
            newHour, more = Step(expDefine[3].Range[1], ttime.hour + dis * expDefine[3].Diff, expDefine[3].Range[2], expDefine[3].Diff)
        end
        if more ~= 0 then
            UpDay(more)
        else
            ttime = os.date('!*t', os.time({year = ttime.year, month = ttime.month, day = ttime.day, hour = newHour, min = expDefine[2].Range[1], sec = expDefine[1].Range[1]}) - timeZone)
        end
    end

    local function UpMin(dis)
        dis = dis or 0
        local newMin, more
        if expDefine[2].Appint then
            newMin, more = NextAppoint(ttime.min + dis * expDefine[2].Diff, expDefine[2].Appint)
        else
            newMin, more = Step(expDefine[2].Range[1], ttime.min + dis * expDefine[2].Diff, expDefine[2].Range[2], expDefine[2].Diff)
        end
        if more ~= 0 then
            UpHour(more)
        else
            ttime = os.date('!*t', os.time({year = ttime.year, month = ttime.month, day = ttime.day, hour = ttime.hour, min = newMin, sec = expDefine[1].Range[1]}) - timeZone)
        end
    end

    local function UpSec(dis)
        dis = dis or 0
        local newSec, more
        if expDefine[1].Appint then
            newSec, more = NextAppoint(ttime.sec + dis * expDefine[1].Diff, expDefine[1].Appint)
        else
            newSec, more = Step(expDefine[1].Range[1], ttime.sec + dis * expDefine[1].Diff, expDefine[1].Range[2], expDefine[1].Diff)
        end
        if more ~= 0 then
            UpMin(more)
        else
            ttime = os.date('!*t', os.time({year = ttime.year, month = ttime.month, day = ttime.day, hour = ttime.hour, min = ttime.min, sec = newSec}) - timeZone)
        end
    end

    local UpTime = {
        year = UpYear,
        month = UpMonth,
        day = UpDay,
        hour = UpHour,
        min = UpMin,
        sec = UpSec,
        wday = UpWDay,
    }

    local function Check(now, define)
        if define.Appint then
            return NextAppoint(now[define.Type], define.Appint) == now[define.Type]
        else
            return Step(define.Range[1], now[define.Type], define.Range[2], define.Diff) == now[define.Type]
        end
    end

    local function GetTime()
        while true do
            local bFail = false
            for _, v in ipairs(expDefine) do
                if not Check(ttime, v) and UpTime[v.Type] then
                    UpTime[v.Type]()
                    bFail = true
                end
            end
            if not bFail then
                break
            end
        end
        time = os.time(ttime) - timeZone
    end
    GetTime()
    return time
end

setmetatable(Cron, {__call = function(self, ...)
    return Cron.next(...)
end})

return Cron