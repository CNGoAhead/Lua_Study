local Aoe = {}

local function Equal(vecA, vecB)
    return math.abs(vecA[1] - vecB[1]) <= 0.000001 and math.abs(vecA[2] - vecB[2]) <= 0.000001 and (not (vecA[3] and vecB[3]) and true or math.abs(vecA[3] - vecB[3]) <= 0.000001)
end

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

local function Crs(vecA, vecB)
    return {0, 0, vecA[1] * vecB[2] - vecA[2] * vecB[1]}
end

local function CrsV(vecA, vecB)
    return vecA[1] * vecB[2] - vecA[2] * vecB[1]
end

local function Mod2(vec)
    return vec[1] * vec[1] + vec[2] * vec[2]
end

local function Mod(vec)
    return math.sqrt(vec[1] * vec[1] + vec[2] * vec[2])
end

local function Mod32(vec)
    return vec[1] * vec[1] + vec[2] * vec[2] + vec[3] * vec[3]
end

local function Mod3(vec)
    return math.sqrt(vec[1] * vec[1] + vec[2] * vec[2] + vec[3] * vec[3])
end

local function Normal(vec)
    local m = Mod(vec)
    return {vec[1] / m, vec[2] / m}
end

local function Rotate(vec, angle)
    local c = math.cos(math.rad(angle))
    local s = math.sin(math.rad(angle))
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
        return (C2 * PB - CB * PC) * Denominator, (B2 * PC - CB * PB) * Denominator
    end
end

-- *      *
--
--
-- *      *
local function Rect(_, x, y)
    return x >= 0 and x <= 1 and y >= 0 and y <= 1 and x + y <= 2
end

-- *
--
--
-- *      *
local function Triangle(_, x, y)
    return x >= 0 and x <= 1 and y >= 0 and y <= 1 and x + y <= 1
end

local function Quadrant1(_, x, y)
    return x >= 0 and y >= 0
end

local function NotQuadrant1(_, x, y)
    return not(x > 0 and y > 0)
end

local function Quadrant12(_, _, y)
    return y >= 0
end

local function Quadrant34(_, _, y)
    return y <= 0
end

local function IsIn(Geometry, posA, posB, posC, poses, quickCheck)
    local ret = {}
    if poses[1] and not poses[1][1] then
        poses = {poses}
    end
    local GetXY = ConstructNewPlane(posA, posB, posC)
    for _, v in ipairs(poses) do
        if (not quickCheck and true or quickCheck(v)) and Geometry(v, GetXY(v)) then
            table.insert(ret, v)
        end
    end
    return ret
end

local function AABB(posA, posB, x, y, r)
    if type(x) == 'table' then
        r = x[3]
        y = x[2]
        x = x[1]
    end
    r = r or 0
    return x >= posA[1] - r
        and x <= posB[1] + r
        and y >= posA[2] - r
        and y <= posB[2] + r
end

local function AABBCircular(posA, posB, x, y, r)
    if type(x) == 'table' then
        r = x[3]
        y = x[2]
        x = x[1]
    end
    local result = x >= posA[1] - r
                and x <= posB[1] + r
                and y >= posA[2] - r
                and y <= posB[2] + r
    if result then
        if x < posA[1] then
            local dx = posA[1] - x
            if y < posA[2] then
                local dy = posA[2] - y
                return dx * dx + dy * dy <= r * r
            elseif y > posB[2] then
                local dy = y - posB[2]
                return dx * dx + dy * dy <= r * r
            end
        elseif x > posB[1] then
            local dx = x - posB[1]
            if y < posA[2] then
                local dy = posA[2] - y
                return dx * dx + dy * dy <= r * r
            elseif y > posB[2] then
                local dy = y - posB[2]
                return dx * dx + dy * dy <= r * r
            end
        end
    end
    return result
end

local function DisPTL(posA, pos)
    return CrsV(posA, pos) / Mod(pos)
end

local function DisPTL2(posA, pos)
    local v = CrsV(posA, pos)
    return (v * v) / Mod2(pos)
end

local function Sector2(poses, start, target, radius, angle)
    local bSemiCircle = angle == 180
    local bReseve = angle > 180
    if bReseve then
        angle = 360 - angle
    end
    local posA = start
    local dir
    if type(target) == "number" then
        dir = Rotate({1, 0}, -target)
    else
        dir = Sub(target, start)
    end

    if bReseve then
        dir = Mul(dir, -1)
    end

    local vdirL = Rotate(dir, angle / 2)
    local vdirR = Rotate(dir, -angle / 2)
    local posC = Add(posA, bSemiCircle and dir or vdirR)
    local posB = Add(posA, vdirL)
    local function quick(pos)
        local x = pos[1] - posA[1]
        local y = pos[2] - posA[2]
        local r = pos[3] + radius
        return x * x + y * y <= r * r
    end
    return IsIn(bSemiCircle and Quadrant12 or (bReseve and NotQuadrant1 or Quadrant1), posA, posB, posC, poses, quick)
end

function Aoe.Sector(poses, start, target, radius, angle)
    local bSemiCircle = angle == 180
    local bReverse = angle > 180
    local posA = start
    local dir
    if type(target) == "number" then
        dir = Rotate({1, 0}, -target)
    else
        dir = Normal(Sub(target, start))
    end

    local vdir = Rotate(dir, angle / 2)
    local vdir2 = Rotate(dir, -angle / 2)
    local vdir3 = bSemiCircle and dir or nil
    local vecN = Crs(vdir, vdir3 or vdir2)
    local vecR = Crs(vdir2, vdir3 or vdir)
    local function quick(pos)
        local x = pos[1] - posA[1]
        local y = pos[2] - posA[2]
        local r = pos[3] + radius
        return x * x + y * y <= r * r
    end

    local function check(pos)
        if Equal(pos, posA) then
            return true
        end

        local v = Sub(pos, posA)

        local r2 = pos[3] * pos[3]

        if bReverse then
            return (CrsV(vdir, v) * vecN[3] <= 0 or CrsV(vdir2, v) * vecR[3] <= 0)
            or (vdir[1] * v[1] <= 0 and vdir[2] * v[2] <= 0 and DisPTL2(vdir, v) <= r2)
            or (vdir2[1] * v[1] <= 0 and vdir2[2] * v[2] <= 0 and DisPTL2(vdir2, v) <= r2)
        else
            local n1 = CrsV(vdir, v) * vecN[3]
            local n2 = CrsV(vdir2, v) * vecR[3]
            return n1 == 0 or n2 == 0 or (n1 > 0 and n2 > 0)
            or (vdir[1] * v[1] >= 0 and vdir[2] * v[2] >= 0 and DisPTL2(vdir, v) <= r2)
            or (vdir2[1] * v[1] >= 0 and vdir2[2] * v[2] >= 0 and DisPTL2(vdir2, v) <= r2)
        end
    end
    local ret = {}
    for _, v in ipairs(poses) do
        if quick(v) and check(v) then
            table.insert(ret, v)
        end
    end
    return ret
end

function Aoe.Sector2(poses, start, target, radius, angle)
    local bSemiCircle = angle == 180
    local bReverse = angle > 180
    if bReverse then
        angle = 360 - angle
    end
    local posA = start
    local dir
    if type(target) == "number" then
        dir = Rotate({1, 0}, -target)
    else
        dir = Normal(Sub(target, start))
    end

    local posB = Add(posA, Rotate(dir, angle / 2))
    local posC = Add(posA, Rotate(dir, -angle / 2))
    local posD = bSemiCircle and Add(posA, dir)

    local ret = {}

    local function quick(pos)
        local x = math.abs(pos[1] - posA[1])
        local y = math.abs(pos[2] - posA[2])
        local r = pos[3] + radius
        if x^2 + y^2 > r^2 then
            return false
        end

        r = pos[3]
        if x^2 + y^2 <= r^2 then
            table.insert(ret, pos)
            return false
        end

        x = math.abs(pos[1] - posB[1])
        y = math.abs(pos[2] - posB[2])
        if x^2 + y^2 <= r^2 then
            table.insert(ret, pos)
            return false
        end
        x = math.abs(pos[1] - posC[1])
        y = math.abs(pos[2] - posC[2])
        if x^2 + y^2 <= r^2 then
            table.insert(ret, pos)
            return false
        end
    end

    local ret2 = IsIn(bSemiCircle and function(pos, x, y)
        return y >= -pos[3]
    end or (bReverse and function(pos, x, y)
        return (x < 0 or y < 0) or (x <= pos[3] and y >= pos[3] and y <= radius) or (y <= pos[3] and x >= pos[3] and x <= raduis)
    end or function(pos, x, y)
        return (x >= 0 and y >= -pos[3]) or (y >= 0 and x >= -pos[3])
    end), posA, posB, bSemiCircle and posD or posC, poses, quick)

    for _, v in ipairs(ret2) do
        table.insert(ret, v)
    end

    return ret
end

function Aoe.Rect(poses, start, target, long, wide)
    local sx,sy,tx,ty = start[1],start[2],target[1],target[2]
    if long == "auto" then
        long = math.sqrt((tx-sx)^2+(ty-sy)^2)
    end

    local dir = Normal(Sub(target, start))
    local bSimple = false
    local w, h
    local lb, rt
    -- 水平或垂直 则直接AABB
    if math.abs(dir[1]) == 1 then
        bSimple = true
        w = long * dir[1]
        h = wide / 2
        lb = {math.min(start[1] + w, start[1]), math.min(start[2] + h, start[2] - h)}
        rt = {math.max(start[1] + w, start[1]), math.max(start[2] + h, start[2] - h)}
    elseif math.abs(dir[2]) == 1 then
        bSimple = true
        w = wide / 2
        h = dir[2] * long
        lb = {math.min(start[1] + w, start[1] - w), math.min(start[2] + h, start[2])}
        rt = {math.max(start[1] + w, start[1] - w), math.max(start[2] + h, start[2])}
    end
    if bSimple then
        local ret = {}
        for _, v in ipairs(poses) do
            if AABBCircular(lb, rt, v) then
                table.insert(ret, v)
            end
        end
        return ret
    else
        local vdir = Rotate(dir, -90)
        local halfW = Mul(vdir, wide / 2)
        local posA = Sub(start, halfW)
        local posB = Add(posA, dir)
        local posC = Add(posA, vdir)
        local posLB = {0, 0}
        local posRT = {long, wide}
        return IsIn(function(pos, x, y)
            return AABBCircular(posLB, posRT, x, y, pos[3])
        end , posA, posB, posC, poses)
    end
end

return Aoe