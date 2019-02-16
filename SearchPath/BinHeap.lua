local BinHeap = Class('BinHeap')

function BinHeap:BinHeap()
    self._vec = {}
    self._size = 0
    self._compare = function(a, b)
        return a < b
    end
end

function BinHeap:Init(func, ...)
    self._compare = func or self._compare
    for _, v in ipairs({...}) do
        self:Add(v)
    end
    return self
end

function BinHeap:Add(v)
    table.insert(self._vec, v)
    self._size = self._size + 1
    self:OnAdd(self._size)
    -- self:OnRemove(1)
end

function BinHeap:Remove(i)
    self._vec[i] = self._vec[self._size]
    self._vec[self._size] = nil
    self._size = self._size - 1
    self:OnRemove(i)
end

function BinHeap:OnAdd(index)
    if index > 1 then
        local cindex = math.floor(index / 2)
        if self._compare(self._vec[index], self._vec[cindex]) then
            self._vec[index], self._vec[cindex] = self._vec[cindex], self._vec[index]
            self:OnAdd(cindex)
        end
    end
end

function BinHeap:OnRemove(index)
    local cindex
    local indexL, indexR
    indexL = index * 2
    indexR = index * 2 + 1
    if indexL <= self._size and indexR <= self._size then
        cindex = self._compare(self._vec[indexL], self._vec[indexR]) and indexL or indexR
    elseif indexL <= self._size then
        cindex = indexL
    else
        return
    end
    self:OnAdd(index)
    self:OnRemove(cindex)
end

function BinHeap:Get(i)
    i = i or 1
    return self._vec[i]
end

function BinHeap:GetSize()
    return self._size
end

function BinHeap:Ipairs()
    return ipairs(self._vec)
end

return BinHeap