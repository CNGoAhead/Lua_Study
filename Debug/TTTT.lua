local function T()
    print(string.find('|CreateBy|', '|CreateBy.-|'))
    print(debug.traceback(), string.find(debug.traceback(), 'CCCC.-%.lua'))
end

local function A()
    T()
end

local l = 'LOGIC ([1]>10,[1]<100)|([2]=1|[2]=2)'

l = string.match(l, 'LOGIC(.*)')
print(l)
l = string.gsub(l, '|', ' or ')
print(l)
l = string.gsub(l, ',', ' and ')
print(l)
l = string.gsub(l, '=', '==')
print(l)
l = string.gsub(l, '%[.-%]', function(a)
    return 'p' .. a
end)

local h = 'return function(p)\n\treturn not not '
local t = '\nend\n'

print(h .. l .. t)

local a = loadstring(h .. l .. t)()
print(a({50, 1}))

return A