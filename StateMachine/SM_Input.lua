local Input = class('Input')

local event = require('cae.dataType.event')

function Input:ctor(...)
    self:initModel(...)
end

function Input:initModel(stateMachine, name, excute, bCanReverse)
    self._stateMachine = stateMachine
    self._name = name
    self._bCanReverse = bCanReverse
    self._excute = excute
    self._reverseStateModels = {}
    self._reverseStateMachineModels = {}
end

local function saveData(model)
    local data = {}
    for k, _ in model.proppairs() do
        data[k] = model.propget(k)
    end
    return data
end

local function loadData(model, data)
    for k, v in pairs(data) do
        model[k] = v
    end
end

function Input:excute(stateModel, ...)
    print("excute")
    local output = {}
    if self._bCanReverse then
        table.insert(self._reverseStateModels, {stateModel, saveData(stateModel)})
        table.insert(self._reverseStateMachineModels, {self._stateMachine._model, saveData(self._stateMachine._model)})
    end
    if self._excute then
        self._excute(output, stateModel, self._stateMachine._model, ...)
    end
    return output
end

function Input:reverse()
    if self._bCanReverse then
        local record = self._reverseStateModels[#self._reverseStateModels]
        if record then
            loadData(record[1], record[2])
        end
        record = self._reverseStateMachineModels[#self._reverseStateMachineModels]
        if record then
            loadData(record[1], record[2])
        end
    end
end

return Input