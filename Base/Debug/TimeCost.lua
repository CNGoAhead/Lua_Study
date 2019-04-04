local TimeCost = Class('TimeCost')

function TimeCost:TimeCost()
    self:Clear()
end

function TimeCost:Clear()
    self._total = 0
    self._endStack = {}
    self._timeMap = {}
end

function TimeCost:Beg()
    table.insert(self._endStack, socket.gettime())
end

function TimeCost:End(key, bPrint)
    local diff = socket.gettime() - self._endStack[#self._endStack]
    self._endStack[#self._endStack] = nil
    self._total = self._total + diff
    if key then
        self._timeMap[key] = self._timeMap[key] or {count = 0, time = 0}
        self._timeMap[key].time = self._timeMap[key].time + diff
        self._timeMap[key].count = self._timeMap[key].count + 1
    end
    if bPrint then
        print('total time = ', self._total)
        if key then
            print(key .. ' cost time / count = ', self._timeMap[key].time .. ' / ' .. self._timeMap[key].count)
        end
    end
end

function TimeCost:ToString()
    local log = {}
    for k, v in pairs(self._timeMap) do
        table.insert(log, k .. ' cost time / count = ' .. v.time .. ' / ' .. v.count)
    end
    return 'total time = ' .. self._total .. '\n' .. table.concat(log, '\n')
end

return function()
    return TimeCost
end