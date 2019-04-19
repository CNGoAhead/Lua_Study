local Branch = class('Branch')

local Model = import('.SM_StateModel')

function Branch:ctor(...)
    self:initModel(...)
end

function Branch:initModel(stateMachine, name, lStateName, rStateName)
    local m = Model:create(self)
    self._name = name
    self._stateMachine = stateMachine
    m:property(
        m.propN("lStateName", lStateName),
        m.propN("rStateName", rStateName)
    )
    self._model = m
end

function Branch:branch(stateModel)
    if self._branch and self._branch(stateModel, self._stateMachine._model) then
        self._stateMachine._model.curState = self._stateMachine._model.states[self._model.rStateName]
        return true
    end
end

function Branch:setBranch(branch)
    self._branch = branch
end

return Branch
