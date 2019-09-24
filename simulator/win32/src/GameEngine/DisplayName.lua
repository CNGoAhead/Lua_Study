local DisplayName = Struct('DisplayName')

local NamesCount = {}

function DisplayName:Init(name)
    NamesCount[name] = (NamesCount[name] or 0) + 1
    Property(self,
    PropR('Name', name or (GetName(self) .. NamesCount[name]))
    )
end

return DisplayName