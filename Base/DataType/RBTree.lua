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

local function LSRotate(_, node)
    local c = node
    local r = node._right
    local p = node._parent
    local flag = Unlink(_, p, c)
    Unlink(_, c, r, 'r')
    Link(_, p, r, flag)
    Link(_, r, c, 'l')
end

local function RSRotate(_, node)
    local c = node
    local l = node._left
    local p = node._parent
    local flag = Unlink(_, p, c)
    Unlink(_, c, l, 'l')
    Link(_, p, l, flag)
    Link(_, l, c, 'r')
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
            elseif c == p._right then
                LRotate(tree, p)
                flash(p)
            end
            p._color = Color.B
            g._color = Color.R
            RRotate(tree, g)
        elseif p == g._right then
            u = g._left or NilNode
            if u._color == Color.R then
                p._color = Color.B
                u._color = Color.B
                g._color = Color.R
                flash(g)
            elseif c == p._left then
                RRotate(tree, p)
                flash(p)
            end
            p._color = Color.B
            g._color = Color.R
            LRotate(tree, g)
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
    node = GetNode(node)
    local c = node
    local l = node._left
    local r = node._right
    local p = node._parent

    Unlink(tree, c, l, 'l')
    Unlink(tree, c, r, 'r')
    local flag = Unlink(tree, p, c)
    local nc = r and LTop(tree, l) or l
    Unlink(tree, nc._parent, nc)
    if not p then
        tree.entry = nc
    else
        Link(tree, p, nc, flag)
    end
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

local function MinMaxDep(tree)
    local min, max = 10000000000000000, 0
    local cache = {}
    local function save(len)
        if len > max then
            max = len
        end
        if len < min then
            min = len
        end
    end
    local rTop = tree:RTop()
    local root = tree.entry
    local len = 0
    while root do
        len = len + 1
        if not root._left and not root._right then
            save(len)
        end
        if root.key == rTop then
            break
        end
        if root._left and not cache[tostring(root) .. tostring(root._left)] then
            cache[tostring(root) .. tostring(root._left)] = true
            root = root._left
        elseif root._right and not cache[tostring(root) .. tostring(root._right)] then
            cache[tostring(root) .. tostring(root._right)] = true
            root = root._right
        elseif root._parent then
            root = root._parent
            len = len - 1
        else
            break
        end
    end
    return min, max
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
    tree.MinMaxDep = MinMaxDep
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