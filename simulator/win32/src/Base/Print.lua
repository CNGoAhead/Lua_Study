local T = require('Base.TString')()
local PrintKV, PrintTb, Print, head, tbs

PrintKV = function(k, v)
    local tp = type(v)
    if tp == 'table' and not tbs[v] then
        print(head .. tostring(k) .. ' =')
        PrintTb(v, head, tbs)
    else
        print(head .. tostring(k) .. ' = ' .. tostring(v))
    end
end

PrintTb = function(t)
    print(head .. '{')
    head = head + '\t'
    tbs[t] = true
    for k, v in pairs(t) do
        PrintKV(k, v)
    end
    head = head - '\t'
    print(head .. '}')
end

Print = function(t)
    head = T''
    tbs = {}
    print('Print At' .. (T(debug.traceback('', 2)) / '\n')[3])
    local tp = type(t)
    if tp == 'table' then
        print(tostring(t) .. ' =')
        PrintTb(t)
    else
        print(tostring(t))
    end
end

return function()
    return Print
end