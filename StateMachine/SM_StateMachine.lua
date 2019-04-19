local StateMachine = class("StateMachine")

local Model = import('.SM_StateModel')
local State = import('.SM_State')
local Branch = import('.SM_Branch')
local Input = import('.SM_Input')
local Output = import('.SM_Output')

function StateMachine:ctor()
    self:initModel()
end

function StateMachine:initModel()
    self._model = Model:create(self)
    self._model:property(
        self._model.propN("reorderDirty", false),
        self._model.propN("curState", nil),
        self._model.propN("states", {}),
        self._model.propN("branchs", {}),
        self._model.propN("inputs", {}),
        self._model.propN("inputHistory", {}),
        self._model.propN("output", Output:create(self))
    )
end

function StateMachine:reorder()
    local states = self._model.states
    local branchs = self._model.branchs
    for _, v in pairs(states) do
        v._model.lBranchName = {}
        v._model.rBranchName = {}
    end
    for _, v in pairs(branchs) do
        if states[v._model.lStateName] then
            table.insert(states[v._model.lStateName]._model.rBranchNames, v._name)
        end
        if states[v._model.rStateName] then
            table.insert(states[v._model.rStateName]._model.lBranchNames, v._name)
        end
    end
    self._model.reorderDirty = false
end

function StateMachine:setData(data)
    local m = self._model
    for k, v in pairs(data) do
        if type(v) ~= "table" then
            v = {k, v}
        end
        if v[1] ~= 'reorderDirty'
        and v[1] ~= 'curState'
        and v[1] ~= 'states'
        and v[1] ~= 'branchs'
        and v[1] ~= 'inputHistory'
        and v[1] ~= 'output'
        then
            m:property(
                m.propNGS(v[1], v[2], v[3], v[4])
            )
        end
    end
    return self
end

function StateMachine:update(diff)
    print("run")
    if self._model.reorderDirty then
        self:reorder()
    end
    if self._model.curState then
        self._model.curState:update(diff)
    end
end

function StateMachine:addBranch(name, lStateName, rStateName, data)
    local branch = Branch:create(self, name, lStateName, rStateName)
    if data then
        branch:setBranch(data)
    end
    self._model.branchs[name] = branch
    self._model.reorderDirty = true
    return self
end

function StateMachine:addState(name, data)
    local state = State:create(self, name)
    if data then
        for k, v in pairs(data) do
            if k == "onEnter" then
                state.onEnter = state.onEnter + v
            elseif k == "onExit" then
                state.onExit = state.onExit + v
            elseif k == "onRun" then
                state.onRun = state.onRun + v
            end
        end
        data.onEnter = nil
        data.onExit = nil
        data.onRun = nil
        state:setData(data)
    end
    self._model.states[name] = state
    self._model.reorderDirty = true
    if self._model.curState == nil then
        self._model.curState = state
    end
    return self
end

function StateMachine:addInput(name, excute, bCanReverse)
    local input = Input:create(self, name, excute, bCanReverse)
    self._model.inputs[name] = input
    return self
end

function StateMachine:input(name, ...)
    if self._model.inputs[name] then
        local data = self._model.inputs[name]:excute(self._model.curState._model, ...)
        local output = self._model.output
        for k, v in pairs(data or {}) do
            print(k, v)
            if output.propfind(k) then
                output[k] = v
            else
                output:property(
                    output.propN(k, v)
                )
                output:onNotify(k, v)
            end
        end
    end
end

function StateMachine:start(name)
    if name then
        self._model.curState = self._model.states[name]
    end
    GMethod.schedule(Handler(self.update, self), 0.2)
end

function StateMachine:pause()
end

function StateMachine:stop()
end

return StateMachine
