local Grid = {Size = {1000, 1000}, Padding = {10, 20, 30, 40}, Space = {15, 25}, bLtR = true, bTtB = true, bHoriz = true}
local ReuseCell = {_bReuse = true, expwidth = {100, 200}, expheight = {50, 150}}
local UnReuseCell = {_bReuse = false, expwidth = {300, 500}, expheight = {250, 350}}

function Grid:Order(cells)
    local count = #cells
    local reuseCell
    for _, v in ipairs(cells) do
        if v._bReuse then
            reuseCell = v
            break
        end
    end
    local layoutWidth = self.Size[1] - self.Padding[1] - self.Padding[2]
    local layoutHeight = self.Size[2] - self.Padding[3] - self.Padding[4]
    local maxX, minX = self.Size[1] - self.Padding[2], self.Padding[1]
    local maxY, minY = self.Size[2] - self.Padding[3], self.Padding[4]
    local startX, startY
    local function initStartX()
        startX = self.bLtR and self.Padding[1] or self.Size[1] - self.Padding[2]
    end
    initStartX()
    local function initStartY()
        startY = self.bTtB and self.Size[2] - self.Padding[3] or self.Padding[4]
    end
    initStartY()
    local function checkX()
        local ret
        if self.bLtR then
            ret = startX
        end
    end
    local function checkY()
    end
    local stepX, stepY
    stepX = self.bLtR and function(cell)
        startX = startX + self.Space[1] + cell.width
    end
    or function(cell)
        startX = startX - self.Space[1] - cell.width
    end
end