local State = class('State')

local Model = import('.SM_StateModel')
local Result = import('.SM_StateResult')
local event = require('cae.dataType.event')
local enum = require('cae.dataType.enum')

State.EState =
    enum(
    {
        'None',
        'Rest',
        'Run'
    }
)

function State:ctor(stateMachine, name)
    self:initModel(stateMachine, name)
    self:initEvent()
end

function State:initEvent()
    event(self, 'Enter')
    event(self, 'Exit')
    event(self, 'Run')
end

function State:initModel(stateMachine, name)
    self._name = name
    self._stateMachine = stateMachine
    self._rBranchs = {}
    self._lBranch = nil
    local m = Model:create(self)
    m:property(
        m.propN("eState", State.EState.None)
    )
    self._model = m
end

function State:tryBranch()
    for _, v in ipairs(self._rBranchs) do
        if v:branch(self._model) then
            return self:exit()
        end
    end
end

function State:update(diff)
    if self._model.estate ~= State.EState.Run then
        self:enter()
    else
        self:tryBranch()
        if self._model.estate == State.EState.Run then
            self:run(diff)
        end
    end
end

function State:run(diff)
    self.Run(diff, self._model, self._stateMachine._model)
end

function State:enter()
    self.Enter(self._model, self._stateMachine._model)
    self._estate = State.EState.Run
end

function State:exit()
    self.Exit(self._model, self._stateMachine._model)
    self._estate = State.EState.Rest
end

function State:setData(data)
    local m = self._model
    for _, v in ipairs(data) do
        m:property(
            m.propNGS(v[1], v[2], v[3], v[4])
        )
    end
end

return State
