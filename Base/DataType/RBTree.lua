-- local RBTree = {}
-- local RBNode = {}

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
    return {key = node, _color = Color.R}
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

local function Unlink(tree, parent, child, flag)
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
    local p, l, r = node._parent, node._left, node._right
    Link(tree, p, newnode, Unlink(tree, p, node))
    Link(tree, newnode, l, Unlink(tree, node, l, 'l'))
    Link(tree, newnode, r, Unlink(tree, node, r, 'r'))
end

local function AdjustTreeOnInsert(tree, node, flag)
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

    if true then
        return
    end

    if not node then
        return
    end
    local p = node._parent
    local g = p and p._parent
    if not p and node._color == Color.R then
        node._color = Color.B
        -- if flag then
        --     LRotate(tree, node)
        -- else
        --     RRotate(tree, node)
        -- end
        -- return
    end
    if not p or not g then
        return
    end
    if g._left and g._left._color == Color.R and g._right and g._right._color == Color.R then
        g._left._color = Color.B
        g._right._color = Color.B
        g._color = Color.R
        return AdjustTreeOnInsert(tree, g, tree._lfunc(node.key, g.key))
    elseif p._color == Color.R then
        if node == p._right then
            -- if not g._parent then
            --     if node == p._left then
            --         RSRotate(tree, p)
            --     end
            --     LSRotate(tree, g)
            -- else
                LRotate(tree, p)
                return AdjustTreeOnInsert(tree, p)
            -- end
        else
            -- if not g._parent then
            --     if node == p._right then
            --         LSRotate(tree, p)
            --     end
            --     RSRotate(tree, g)
            -- else
                p._color = Color.B
                g._color = Color.R
                RRotate(tree, g)
                return AdjustTreeOnInsert(tree, g._right)
            -- end
        end
        -- if node == p._right and (not g._left or g._left._color == Color.B) or (not g._right or g._right._color == Color.B) then
        --     LRotate(tree, p)
        --     return AdjustTreeOnInsert(tree, p)
        -- elseif node == p._left and (not g._left or g._left._color == Color.B) or (not g._right or g._right._color == Color.B) then
        --     p._color = Color.B
        --     g._color = Color.R
        --     RRotate(tree, g)
        --     return AdjustTreeOnInsert(tree, g._right)
        -- end
        -- if g._right == p then
        --     if p._left == node then
        --         RRotate(tree, p)
        --         node, p = p, node
        --     end
        --     p._color = Color.B
        --     g._color = Color.R
        --     LRotate(tree, g)
        -- else
        --     if p._right == node then
        --         LRotate(tree, p)
        --         node, p = p, node
        --     end
        --     p._color = Color.B
        --     g._color = Color.R
        --     RRotate(tree, g)
        -- end
    end
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
        return
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
    AdjustTreeOnInsert(tree, node)
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
        -- Replace(tree, c, nc)
    elseif not r then
        nc = l or NilNode
        -- Replace(tree, c, nc)
    else
        nc = LTop(tree, r) or NilNode
        color = nc._color
        nr = nc._right or NilNode
        Replace(tree, nc, nr)
        nc._color = c._color
    end
    Replace(tree, c, nc)

    if nc and nc ~= NilNode and color == Color.B then
        AdjustTreeOnDelete(tree, nc._right)
    end

    if true then
        return
    end

    local nc = ((r and l) and LTop(tree, r)) or l or r
    color = nc._color
    Unlink(tree, c, l, 'l')
    Unlink(tree, c, r, 'r')
    local flag = Unlink(tree, p, c)
    Unlink(tree, nc._parent, nc)
    Link(tree, p, nc, flag)
    Link(tree, nc, l, 'l')
    Link(tree, nc, r, 'r')
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
        return not Assert(node._left) or not Assert(node._right)
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
    tree.Find = GetNode
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
        new = MakeTree
    }
end