local BaseModel = require("model.BaseModel")
local StateResult = class("StateResult", BaseModel)

local enum = require("cae.dataType.enum")

StateResult.EState = enum(
    {
        'None',
        'Running',
        'Complete',
    }
)

function StateResult:onCreate()
end

return StateResult
