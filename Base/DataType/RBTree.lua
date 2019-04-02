local Color = {
    R = 1,
    B = 2,
}

local NilNode = {}
setmetatable(NilNode, {
    __index = {_color = Color.B},
    __newindex = function()
        return
    end
})

local function MakeNode(node)
    if type(node) == 'table' and node.__is_node__ then
        return node
    end
    local tbl = {key = node, _color = Color.R, _left = false, _right = false}
    local meta = {_parent = false}
    setmetatable(meta, {__mode = 'v'})
    setmetatable(tbl, meta)
    return tbl
end


local function GetNode(tree, node)
    node = MakeNode(node)
    local root = tree.entry
    while root do
        if tree._lfunc(node.key, root.key) then
            root = root._left
        elseif tree._lfunc(root.key, node.key) then
            root = root._right
        else
            return root
        end
    end
end

local function LTop(_, node)
    while node._left do
        node = node._left
    end
    return node
end

local function RTop(_, node)
    while node._right do
        node = node._right
    end
    return node
end

local function Unlink(_, parent, child, flag)
    if child then
        child._parent = nil
    end
    if not parent or parent == NilNode or parent == child then
        return
    end
    if flag == 'l' or parent._left == child then
        parent._left = nil
        return 'l'
    elseif flag == 'r' or parent._right == child then
        parent._right = nil
        return 'r'
    end
end

local function Link(tree, parent, child, flag)
    if not child or child == NilNode or parent == child then
        return
    end
    if not parent or parent == NilNode then
        tree.entry = child
        child._color = Color.B
        child._parent = NilNode
        return
    end
    if not flag and tree._lfunc(child.key, parent.key) or flag == 'l' then
        parent._left = child
        child._parent = parent
        return 'l'
    elseif not flag and tree._lfunc(parent.key, child.key) or flag == 'r' then
        parent._right = child
        child._parent = parent
        return 'r'
    elseif tree and tree._efunc then
        tree._efunc(parent.key, child.key)
        return 'e'
    end
end

local function LRotate(_, node)
    local c = node
    if not c._right then
        return
    end
    local r = c._right or NilNode
    local p = c._parent or NilNode
    local rl = r._left or NilNode
    local flag = Unlink(_, p, c)
    Unlink(_, c, r, 'r')
    Unlink(_, r, rl, 'l')
    Link(_, p, r, flag)
    Link(_, c, rl, 'r')
    Link(_, r, c, 'l')
end

local function RRotate(_, node)
    local c = node
    if not c._left then
        return
    end
    local l = c._left or NilNode
    local p = c._parent or NilNode
    local lr = l._right or NilNode
    local flag = Unlink(_, p, c)
    Unlink(_, c, l, 'l')
    Unlink(_, l, lr, 'r')
    Link(_, p, l, flag)
    Link(_, c, lr, 'l')
    Link(_, l, c, 'r')
end

local function Replace(tree, node, newnode)
    if not node or node == NilNode then
        return
    end
    local p, l, r = node._parent, node._left, node._right
    local flag = Unlink(tree, p, node)
    Unlink(tree, node, l, 'l')
    Unlink(tree, node, r, 'r')
    Link(tree, newnode, r, 'r')
    Link(tree, newnode, l, 'l')
    Link(tree, p, newnode, flag)
end

local function AdjustTreeOnInsert(tree, node)
    local c, p, g, u
    local function flash(n)
        c = n
        p = c._parent or NilNode
        g = p._parent or NilNode
    end

    flash(node)

    while c ~= NilNode and p._color == Color.R do
        if p == g._left then
            u = g._right or NilNode
            if u._color == Color.R then
                p._color = Color.B
                u._color = Color.B
                g._color = Color.R
                flash(g)
            else
                if c == p._right then
                    flash(p)
                    LRotate(tree, c)
                    flash(c)
                end
                p._color = Color.B
                g._color = Color.R
                RRotate(tree, g)
            end
        elseif p == g._right then
            u = g._left or NilNode
            if u._color == Color.R then
                p._color = Color.B
                u._color = Color.B
                g._color = Color.R
                flash(g)
            else
                if c == p._left then
                    flash(p)
                    RRotate(tree, c)
                    flash(c)
                end
                p._color = Color.B
                g._color = Color.R
                LRotate(tree, g)
            end
        else
            c._color = Color.B
        end
        flash(c)
    end

    tree.entry._color = Color.B
end

local function AdjustTreeOnDelete(tree, node)
    local c, p, g
    local function flash(n)
        c = n or NilNode
        p = c._parent or NilNode
        g = p._parent or NilNode
    end

    flash(node)

    local b, bl, br
    local function flashB(n)
        b = n or NilNode
        bl = b._left or NilNode
        br = b._right or NilNode
    end

    while c ~= NilNode and c ~= tree.entry and c._color == Color.B do
        if c == p._left then
            flashB(p._right)
            if b._color == Color.R then
                b._color = Color.B
                p._color = Color.R
                LRotate(tree, p)
                flash(c)
                flashB(p._right)
            else
                if bl._color == Color.B and br._color == Color.B then
                    b._color = Color.R
                    flash(p)
                else
                    if br._color == Color.B then
                        bl._color = Color.B
                        b._color = Color.R
                        RRotate(tree, b)
                        flash(c)
                        flashB(p._right)
                    end
                    b._color = p._color
                    p._color = Color.B
                    br._color = Color.B
                    LRotate(tree, p)
                    flash(tree.entry)
                end
            end
        else
            flashB(p._left)
            if b._color == Color.R then
                b._color = Color.B
                p._color = Color.R
                RRotate(tree, p)
                flash(c)
                flashB(p._left)
            else
                if bl._color == Color.B and br._color == Color.B then
                    b._color = Color.R
                    flash(p)
                else
                    if bl._color == Color.B then
                        br._color = Color.B
                        b._color = Color.R
                        LRotate(tree, b)
                        flash(c)
                        flashB(p._left)
                    end
                    b._color = p._color
                    p._color = Color.B
                    bl._color = Color.B
                    RRotate(tree, p)
                    flash(tree.entry)
                end
            end
        end
    end

    c._color = Color.B
end

local function Insert(tree, node)
    node = MakeNode(node)
    local root = tree.entry
    if not root then
        tree.entry = node
        node._color = Color.B
        return node.key
    end
    local last
    local f
    while root do
        last = root
        if tree._lfunc(node.key, root.key) then
            f = 'l'
            root = root._left
        elseif tree._lfunc(root.key, node.key) then
            f = 'r'
            root = root._right
        else
            f = 'e'
            break
        end
    end
    Link(tree, last, node, f)
    if f ~= 'e' then
        AdjustTreeOnInsert(tree, node)
        return node.key
    else
        return last.key
    end
end

local function Delete(tree, node)
    node = GetNode(tree, node)
    if not node or node == NilNode then
        return
    end
    local c = node
    local l = node._left
    local r = node._right
    local p = node._parent
    local nc
    local nr

    local color = c._color

    if not l then
        nc = r or NilNode
    elseif not r then
        nc = l or NilNode
    else
        nc = LTop(tree, r) or NilNode
        color = nc._color
        nr = nc._right or NilNode
        Replace(tree, nc, nr)
        nc._color = c._color
    end
    Replace(tree, c, nc)

    if nc and nc ~= NilNode and color == Color.B then
        AdjustTreeOnDelete(tree, nc)
    end

    return node.key
end

local function ToVector(node, vec)
    vec = vec or {}
    if node then
        ToVector(node._left, vec)
        table.insert(vec, node.key)
        ToVector(node._right, vec)
    end
    return vec
end

local function Assert(node)
    if node then
        local p = node._parent or NilNode
        if node._color == Color.R and p._color == Color.R then
            return false
        end
        return Assert(node._left) and Assert(node._right)
    end
    return true
end

local function MakeTree(lfunc, efunc)
    lfunc = lfunc or function(a, b)
        return a < b
    end
    local tree = {__is_tree__ = true, _lfunc = lfunc, _efunc = efunc}
    tree.Insert = Insert
    tree.Delete = Delete
    tree.Find = function(self, key)
        local node = GetNode(self, key)
        return node and node.key or nil
    end
    tree.Clear = function()
        tree.entry = nil
    end
    tree.ToVector = function(self)
        return ToVector(self.entry)
    end
    tree.Assert = function(self)
        return Assert(self.entry)
    end
    tree.LTop = function(self)
        local node = LTop(self, self.entry)
        return node and node.key
    end
    tree.RTop = function(self)
        local node = RTop(self, self.entry)
        return node and node.key
    end
    return tree
end

return function()
    return {
        New = MakeTree
    }
end