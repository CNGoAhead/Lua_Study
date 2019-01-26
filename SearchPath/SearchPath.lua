local BinHeap = require('SearchPath.BinHeap')

local INT_MAX = 2147483647
local INT_MIN = (-INT_MAX - 1)

local function ExpectDistance(pos1, pos2)
    local diffX = math.abs(pos1.x - pos2.x)
    local diffY = math.abs(pos1.y - pos2.y)
    return math.min(diffX, diffY) * 14 + math.abs(diffX - diffY) * 10
end

local function CalcuDistance(pos1, pos2, dps, speed)
    local dis = ExpectDistance(pos1,pos2)
    if pos2.height > 0 then
        return dis + pos2.height / dps * speed
    elseif pos2.height < 0 then
        return INT_MAX
    else
        return dis
    end
end

local function SearchNearGround(map, ground, target)
    local ret = BinHeap.new():Init(function(a, b)
        return a.distance < b.distance
    end)
    diffX = {1, 1, -1, -1, 1, -1, 0, 0}
    diffY = {1, -1, 1, -1, 0, 0, 1, -1}
    local cur
    for i = 1, 8 do
        local index = map:GetIndex(ground.x + diffX[i], ground.y + diffY[i])
        cur = map:GetGround(index)
        if cur then
            ret:Add({index = index, distance = ExpectDistance(cur, target)})
        end
    end
    return ret
end

local function Clone(t)
    local r = {}
    for k, v in pairs(t) do
        r[k] = v
    end
    return r
end

local function printPath(map, path)
    local m = {}
    local function IsIn(index)
        for i, v in ipairs(path or {}) do
            if v == index then
                return i
            end
        end
        return false
    end
    for i = 1, map.width do
        for j = 1, map.height do
            local index = map:GetIndex(i, j)
            local i = IsIn(index)
            if i then
                table.insert(m, string.format('[%d]', i % 10))
            else
                local g = map:GetGround(index)
                -- table.insert(m, string.format('[%d]',index))
                table.insert(m, (g.x == map.width and g.y == 1) and '[E]' or ((g.x == 1 and g.y == map.height) and '[S]' or (g.height == 0 and '[ ]' or '[+]')))
            end
        end
        table.insert(m, '\n')
    end
    print(table.concat(m, ''))
    Sleep(0.5)
end

local function Search(map, cur, target, path, close, walk, heap, repeatClose)
    repeatClose = repeatClose or {}
    if cur == target then
        return path
    end
    local near = SearchNearGround(map, cur, target)
    local t = {}
    for _, v in near:Ipairs() do
        if not close[v.index] then
            table.insert(t, v.index)
        end
    end

    local function AddClose(c)
        for _, v in pairs(t) do
            c[v] = true
        end
    end

    local function RemoveClose(c)
        for _, v in pairs(t) do
            c[v] = false
        end
    end

    while near:GetSize() > 0 do
        local first = near:Get()
        local index = first.index
        local ground = map:GetGround(index)
        if ground.height ~= 0 or close[index] then
            near:Remove(1)
        else
            local newPath = Clone(path)
            local newClose = Clone(close)
            table.insert(newPath, index)
            AddClose(newClose)
            local newWalk = CalcuDistance(cur, ground, 1, 10)
            local newDistance = first.distance
            heap:Add({cur = ground, path = newPath, close = newClose, distance = newDistance, walk = walk + newWalk})
            close[index] = true
            -- for i, v in heap:Ipairs() do
            --     v.close[index] = true
            -- end
            local t = heap:Get()
            -- print('----Add----', newDistance + walk + newWalk)
            -- printPath(map, newPath)
            local ret = Search(map, t.cur, target, t.path, t.close, t.walk, heap)
            if ret then
                return ret
            else
                near:Remove(1)
                table.remove(path, #path)
            end
        end
    end
    heap:Remove(1)
    local t = heap:Get()
    if t then
        return Search(map, t.cur, target, t.path, t.close, t.walk, heap)
    else
        return false
    end
end

local function SearchPath(map, begin, over)
    local index = map:GetIndex(begin.x, begin.y)
    local closeIndex = {[index] = true}
    local path = {index}
    local distance = ExpectDistance(begin, over)
    local heap = BinHeap.new():Init(function(a, b)
        local la = a.distance + a.walk
        local lb = b.distance + b.walk
        if la == lb then
            return #a.path > #b.path
        else
            return la < lb
        end
    end, {cur = begin, path = path, close = closeIndex, distance = distance, walk = 0})
    return Search(map, begin, over, path, closeIndex, 0, heap)
end

return SearchPath