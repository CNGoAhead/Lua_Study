local Aoe = {}

-- local function Vec2(x, y)
--     if type(x) == 'table' then
--         return {x = x[1] or x.x, y = x[2] or x.y}
--     else
--         return {x = x, y = y}
--     end
-- end

-- local function Sub(vecA, vecB)
--     return {x = vecA.x - vecB.x, y = vecA.y - vecB.y}
-- end

-- local function Dot(vecA, vecB)
--     return vecA.x * vecB.x + vecA.y * vecB.y
-- end

local bTestNewAoe = false

local function Add(vecA, vecB)
    return {vecA[1] + vecB[1], vecA[2] + vecB[2]}
end

local function Sub(vecA, vecB)
    return {vecA[1] - vecB[1], vecA[2] - vecB[2]}
end

local function Mul(vec, m, n)
    return {vec[1] * m, vec[2] * (n or m)}
end

local function Dot(vecA, vecB)
    return vecA[1] * vecB[1] + vecA[2] * vecB[2]
end

local function Mod(vec)
    return math.sqrt(vec[1] * vec[1] + vec[2] * vec[2])
end

local function Normal(vec)
    local m = Mod(vec)
    return {vec[1] / m, vec[2] / m}
end

local function Rotate(vec, angle)
    local c = math.cos(angle)
    local s = math.sin(angle)
    return {vec[1] * c + vec[2] * s, -vec[1] * s + vec[2] * c}
end

--     A            -->C
--                  -->|
--                  -->v
-- B                -->|
--          C       -->A----u----B
local function ConstructNewPlane(posA, posB, posC)
    local AB = Sub(posB, posA)
    local AC = Sub(posC, posA)
    local C2 = Dot(AC, AC)
    local CB = Dot(AC, AB)
    local B2 = Dot(AB, AB)
    local Denominator = 1 / (C2 * B2 - CB * CB)
    return function(pos)
        local AP = Sub(pos, posA)
        local PB = Dot(AP, AB)
        local PC = Dot(AP, AC)
        -- local x = pos[1] - posA[1]
        -- local y = pos[2] - posA[2]
        -- local PB = x * AB[1] + y * AB[2]
        -- local PC = x * AC[1] + y * AC[2]
        return (C2 * PB - CB * PC) * Denominator, (B2 * PC - CB * PB) * Denominator
    end
end

-- *      *
--
--
-- *      *
local function Rect(x, y)
    return x >= 0 and x <= 1 and y >= 0 and y <= 1 and x + y <= 2
end

-- *
--
--
-- *      *
local function Triangle(x, y)
    return x >= 0 and x <= 1 and y >= 0 and y <= 1 and x + y <= 1
end

-- *
--     *
--       *
-- *      *
local function Sector(x, y)
    return x >= 0 and x <= 1 and y >= 0 and y <= 1 and x * x + y * y <= 1
end


local function IsIn(Geometry, posA, posB, posC, poses, quickCheck)
    local ret = {}
    if poses[1] and not poses[1][1] then
        poses = {poses}
    end
    local GetXY = ConstructNewPlane(posA, posB, posC)
    for _, v in ipairs(poses) do
        if (not quickCheck and true or quickCheck(v)) and Geometry(GetXY(v)) then
            table.insert(ret, v)
        end
    end
    return ret
end

function Aoe.isInRect(posA, posB, pos)
    return pos[1] >= posA[1]
        and pos[1] <= posB[1]
        and pos[2] >= posA[2]
        and pos[2] <= posB[2]
end

function Aoe.circlePoint(pointTab,target,radius)
    local result = {}
    local lb = {target[1] - radius, target[2] - radius}
    local rt = {target[1] + radius, target[2] + radius}
    for k,v in ipairs(pointTab) do
        if Aoe.isInRect(lb, rt, v) and (v[1]-target[1])^2+(v[2]-target[2])^2<=(radius+v[3])^2 then
            table.insert(result,v)
        end
    end
    return result
end

local function sectorPoint(pointTab,startPoint,radius,angle,target)
    local direction
    if type(target) == "number" then
        direction = target
    else
        direction = math.deg(math.atan((target[2]-startPoint[2])/(target[1]-startPoint[1])))
        if target[2]-startPoint[2]<0 and target[1]-startPoint[1]<0 then
            direction = direction + 180
        end
        if target[2]-startPoint[2]>0 and target[1]-startPoint[1]<0 then
            direction = direction + 180
        end
    end

    local angle1 = direction-angle/2
    local angle2 = direction+angle/2
    angle1 = angle1<0 and angle1+360 or angle1
    angle1 = angle1>360 and angle1-360 or angle1
    angle2 = angle2<0 and angle2+360 or angle2
    angle2 = angle2>360 and angle2-360 or angle2

    local posA = startPoint
    local posB = {startPoint[1] + radius * math.cos(math.rad(angle1)), startPoint[2] + radius * math.sin(math.rad(angle1))}
    local posC = {startPoint[1] + radius * math.cos(math.rad(angle2)), startPoint[2] + radius * math.sin(math.rad(angle2))}
    local radius2 = radius * radius
    local function quick(pos)
        local x = pos[1] - posA[1]
        local y = pos[2] - posA[2]
        return x * x + y * y <= radius2
    end
    return IsIn(Sector, posA, posB, posC, pointTab, quick)
end

function Aoe.sectorPoint(pointTab,startPoint,radius,angle,target)
    local direction
    if type(target) == "number" then
        direction = target
    else
        direction = math.deg(math.atan((target[2]-startPoint[2])/(target[1]-startPoint[1])))
        if target[2]-startPoint[2]<0 and target[1]-startPoint[1]<0 then
            direction = direction + 180
        end
        if target[2]-startPoint[2]>0 and target[1]-startPoint[1]<0 then
            direction = direction + 180
        end
    end

    local result = {}
    local angle1 = direction-angle/2
    local angle2 = direction+angle/2
    angle1 = angle1<0 and angle1+360 or angle1
    angle1 = angle1>360 and angle1-360 or angle1
    angle2 = angle2<0 and angle2+360 or angle2
    angle2 = angle2>360 and angle2-360 or angle2
    for k,v in ipairs(pointTab) do
        local isMeet1 = false
        local isMeet2 = false
        if math.sqrt((v[1]-startPoint[1])*(v[1]-startPoint[1])+(v[2]-startPoint[2])*(v[2]-startPoint[2]))-v[3]<=radius then 
            if (0<=angle1 and angle1<90) or (angle1>270 and angle1<=360) then
                if (((v[1]-startPoint[1])*math.tan(math.rad(angle1))))<=((v[2]-startPoint[2]))+math.abs(v[3]/math.cos(math.rad(angle1))) then
                    isMeet1 = true
                end
            elseif angle1==90 then
                if v[1]<=startPoint[1]+v[3] then
                    isMeet1 =true
                end
            elseif angle1==270 then
                if v[1]>=startPoint[1]-v[3] then
                    isMeet1 = true
                end
            else
                if ((v[1]-startPoint[1])*math.tan(math.rad(angle1)))>=(v[2]-startPoint[2])-math.abs(v[3]/math.cos(math.rad(angle1))) then
                    isMeet1 = true
                end
            end

            if (0<=angle2 and angle2<90) or (angle2>270 and angle2<=360) then
                if ((v[1]-startPoint[1])*math.tan(math.rad(angle2)))>=(v[2]-startPoint[2])-math.abs(v[3]/math.cos(math.rad(angle2))) then
                    isMeet2 = true
                end
            elseif angle2==90 then
                if v[1]>=startPoint[1]-v[3] then
                    isMeet2 =true
                end
            elseif angle2==270 then
                if v[1]<=startPoint[1]+v[3] then
                    isMeet2 = true
                end
            else
                if ((v[1]-startPoint[1])*math.tan(math.rad(angle2)))<=(v[2]-startPoint[2])+math.abs(v[3]/math.cos(math.rad(angle2))) then
                    isMeet2 = true
                end
            end

            if isMeet1 and isMeet2 then
                table.insert(result,v)
            end
        end
    end
    return result
end

local function line(pointTab,startPoint,long,wide,target)
    local sx,sy,tx,ty = startPoint[1],startPoint[2],target[1],target[2]
    if long == "auto" then
        long = math.sqrt((tx-sx)^2+(ty-sy)^2)
    end

    local dir = Normal(Sub(target, startPoint))
    local bSimple = false
    local w, h
    if math.abs(dir[1]) == 1 then
        bSimple = true
        w = long * dir[1]
        h = wide / 2
    elseif math.abs(dir[2]) == 1 then
        bSimple = true
        w = wide / 2
        h = dir[2] * long
    end
    if bSimple then
        local ret = {}
        local posA = {math.min(startPoint[1] + w, startPoint[1] - w), math.min(startPoint[2] + h, startPoint[2])}
        local posB = {math.max(startPoint[1] + w, startPoint[1] - w), math.max(startPoint[2] + h, startPoint[2])}
        for _, v in ipairs(pointTab) do
            if Aoe.isInRect(posA, posB, v) then
                table.insert(ret, v)
            end
        end
        return ret
    else
        local vdir = Rotate(dir, 90)
        local halfW = Mul(vdir, wide / 2)
        local posA = Sub(startPoint, halfW)
        local posB = Add(posA, Mul(dir, long))
        local posC = Add(startPoint, halfW)
        -- local maxX = math.max(posA[1], posB[1])
        -- local maxY = math.max(posA[2], posB[2])
        -- local minX = math.min(posA[1], posB[1])
        -- local minY = math.min(posA[2], posB[2])
        -- local function quick(pos)
        --     return pos[1] >= minX and pos[1] <= maxX and pos[2] >= minY and pos[2] <= maxY
        -- end
        return IsIn(Rect, posA, posB, posC, pointTab)
    end
end

function Aoe.line(pointTab,startPoint,long,wide,target)
    local sx,sy,tx,ty = startPoint[1],startPoint[2],target[1],target[2]
    if long == "auto" then
        long = math.sqrt((tx-sx)^2+(ty-sy)^2)
    end
    local result = {}
    wide = wide/2
    if sy == ty then
        for k,v in ipairs(pointTab) do
            if sx<tx then
                if sx<=v[1]+v[3] and v[1]-v[3]<=sx+long and sy-wide<=v[2]+v[3] and v[2]-v[3]<=sy+wide then
                    table.insert(result,v)
                end
            else
                if sx-long<=v[1]+v[3] and v[1]-v[3]<=sx and sy-wide<=v[2]+v[3] and v[2]-v[3]<=sy+wide then
                    table.insert(result,v)
                end
            end
        end
    elseif sx == tx then
        for k,v in ipairs(pointTab) do
            if sy<ty then
                if sy<=v[2]+v[3] and v[2]-v[3]<=sy+long and sx-wide<=v[1]+v[3] and v[1]-v[3]<=sx+wide then
                    table.insert(result,v)
                end
            else
                if sy-long<=v[2]+v[3] and v[2]-v[3]<=sy and sx-wide<=v[1]+v[3] and v[1]-v[3]<=sx+wide then
                    table.insert(result,v)
                end
            end
        end
    else
        local d = (ty-sy)/(tx-sx)      -- 斜率
        local a = sy-d*sx
        local rad = math.atan(d)
        local a1 = a-wide/math.cos(rad)
        local a2 = a+wide/math.cos(rad)
        local d2 = -1/d
        local rad2 = math.atan(d2)
        local a21 = sy-d2*sx
        local a22 = a21+long/math.cos(rad2)
        if sy>ty then
            a22 = a21-long/math.cos(rad2)
            a21,a22=a22,a21
        end
        for k,v in ipairs(pointTab) do
            if v[2]>=d*v[1]+a1-v[3]/math.cos(rad) and v[2]-v[3]/math.cos(rad)<=d*v[1]+a2 and v[2]>=d2*v[1]+a21-v[3]/math.cos(rad2) and v[2]-v[3]/math.cos(rad2)<=d2*v[1]+a22 then
                table.insert(result,v)
            end
        end
    end
    return result
end

function Aoe.chain(pointTab,startPoint,maxDis,num)
    local result = {startPoint}
    local dump = {}
    local index = 1
    while index<=num do
        local isFind = false
        local disTemp = 100000
        local key = 0
        for k,v in ipairs(pointTab) do
            local dis = math.sqrt((v[1]-startPoint[1])*(v[1]-startPoint[1])+(v[2]-startPoint[2])*(v[2]-startPoint[2]))-startPoint[3]-v[3]
            if not dump[v] and dis<disTemp and dis<=maxDis then
                result[index] = v
                disTemp = dis
                key = k
                isFind = true
            end
        end
        if isFind then
            startPoint = result[index]
            dump[startPoint]=1
            index = index+1
        else
            break
        end
    end
    return result
end
-- --[[
--     @desc: 
--     author:{author}
--     time:2018-05-18 10:55:49
--     --@pointTab:
-- 	--@target:{{10,23},{14,13}}
-- 	--@radius: 
--     return
-- ]]
-- function Aoe.rectOverSegmentLine(pointTab,target,radius)
--     local lp1 = Math.pointObj(target[1][1],target[1][2])
--     local lp2 = Math.pointObj(target[2][1],target[2][2])
--     local segment = Math.lineSegmentObj(lp1,lp2)
--     for _,avater in pointTab do
--         local objPos = Math.pointObj(avater[1],avater[2])
--         local pPos = Math.getProjectionPos()
--     end
-- end

if bTestNewAoe then
    for i = 1, 100 do
        local start = {math.random(-10, 10), math.random(-10, 10)}
        local target = {math.random(-10, 10), math.random(-10, 10)}
        local radius = math.random(1, 5)
        local angle = math.random(0, 360)
        local long = math.random(1, 5)
        local wide = math.random(1, 5)
        local pos = {}
        for i = 1, 1000000 do
            table.insert(pos, {math.random(-10, 10), math.random(-10, 10), 0})
        end
        local t = socket.gettime()
        local r1 = line(pos, start, long, wide, target)
        print('----LOG----:line', socket.gettime() - t)
        t = socket.gettime()
        local r2 = Aoe.line(pos, start, long, wide, target)
        print('----LOG----:Aoe.line', socket.gettime() - t)
        local function key(p)
            return string.format('%04d-%04d', p[1], p[2])
        end
        -- assert(#r1 == #r2)
        -- if #r1 ~= #r2 then
        --     print('----LOG----: start = ', start[1], start[2])
        --     print('----LOG----: end = ', target[1], target[2])
        --     print('----LOG----: wide = ', wide)
        --     print('----LOG----: long = ', long)
        --     local mapA = {}
        --     local mapB = {}
        --     for _, v in ipairs(r1) do
        --         mapA[key(v)] = v
        --     end
        --     for _, v in ipairs(r2) do
        --         mapB[key(v)] = v
        --     end
        --     print('----LOG----:mapA')
        --     for k, v in pairs(mapA) do
        --         if not mapB[k] then
        --             dump(v)
        --         end
        --     end
        --     print('----LOG----:mapB')
        --     for k, v in pairs(mapB) do
        --         if not mapA[k] then
        --             dump(v)
        --         end
        --     end
        -- end
        t = socket.gettime()
        r1 = sectorPoint(pos, start, radius, angle, target)
        print('----LOG----:sectorPoint', socket.gettime() - t)
        t = socket.gettime()
        r2 = Aoe.sectorPoint(pos, start, long, wide, target)
        print('----LOG----:Aoe.sectorPoint', socket.gettime() - t)
        -- assert(#r1 == #r2)
        if #r1 ~= #r2 then
            print('----LOG----: start = ', start[1], start[2])
            print('----LOG----: end = ', target[1], target[2])
            print('----LOG----: rad = ', radius)
            print('----LOG----: angle = ', angle)
            local mapA = {}
            local mapB = {}
            for _, v in ipairs(r1) do
                mapA[key(v)] = v
            end
            for _, v in ipairs(r2) do
                mapB[key(v)] = v
            end
            print('----LOG----:mapA')
            for k, v in pairs(mapA) do
                if not mapB[k] then
                    dump(v)
                end
            end
            print('----LOG----:mapB')
            for k, v in pairs(mapB) do
                if not mapA[k] then
                    dump(v)
                end
            end
        end
    end
end
return Aoe