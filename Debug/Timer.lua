
--定时器模块
local Timer = {}

--定时器数据
local _timerGroup =
{
    --{k -> {callback, interval, elapse}}
    handlers = {},
    --{k, true}
    removes = {},
    --随机定时器索引
    randomTimerId = 0,
}

--挂接了定时器的Node列表
local _timerNodes = {}

--触发逻辑
--@param group 定时器数据
--@param dt 流逝时间
--@return 定时器是否还存在
local function _trigger(group, dt, node)
    if not group then
        return false
    end

    local rmvs = group.removes
    --触发
    for k,handler in pairs(group.handlers) do
        handler[3] = handler[3] + dt
        if handler[3] >= handler[2] and not (rmvs and rmvs[k]) then
            handler[1](handler[3], k, node)
            handler[3] = 0
        end
    end

    --移除
    for k in pairs(rmvs) do
        rmvs[k] = nil
        group.handlers[k] = nil
    end

    return not not next(group.handlers)
end

--全局调度定时器
local function _timerFunc(dt)
    --触发全局定时器
    _trigger(_timerGroup, dt)

    --触发Node定时器
    for i=#_timerNodes,1,-1 do
        local node = _timerNodes[i]
        if not _trigger(node._timerGroup, dt, node) then
            node._timerGroup = nil
            table.remove(_timerNodes, i)
        end
    end
end

--开启全局定时器
local _globalTimerId = nil
local function _timerOpen()
    if not _globalTimerId then
        _globalTimerId = _G.cc.Director:getInstance():getScheduler():scheduleScriptFunc(_timerFunc, 0, false)
    end
end
--关闭全局定时器
local function _timerClose()
    if _globalTimerId then
        _G.cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_globalTimerId)
        _globalTimerId = nil
    end
end

--获取一个新的定时器唯一标识
local id = 0
local function _getRandomTimerKey(node)
    id = id + 1
    return id
    -- local group = node and node._timerGroup or _timerGroup
    -- group.randomTimerId = group.randomTimerId + 1
    -- return "RandomTimerId_" .. group.randomTimerId
end

--添加全局定时器
--@param callback 定时器触发回调，函数原型：function callback(dt, timerKey)
--@param interval 定时器触发时间间隔，单位秒
--@param timerKey 定时器唯一标识，传nil意味着会随机生成一个定时器标识
--@return 返回定时器唯一标识
function Timer.addTimer(callback, interval, timerKey)
    assert("function" == type(callback), "addTimer callback must be function")
    -- if not _globalTimerId then
    --     _timerOpen()
    -- end

    timerKey = timerKey or _getRandomTimerKey()
    _timerGroup.handlers[timerKey] = {callback, interval or 0, 0}

    --正在移除则清掉
    _timerGroup.removes[timerKey] = nil
    return timerKey
end

--添加全局定时器，触发一次后自动销毁
--@param callback 定时器触发回调，函数原型：function callback(dt, timerKey)
--@param interval 定时器触发时间间隔，单位秒
--@param timerKey 定时器唯一标识，传nil意味着会随机生成一个定时器标识
--@return 返回定时器唯一标识
function Timer.addTimerOnce(callback, interval, timerKey)
    assert("function" == type(callback), "addTimer callback must be function")
    local function _callback(dt, key)
        Timer.removeTimer(key)
        callback(dt, key)
    end
    return Timer.addTimer(_callback, interval, timerKey)
end

--销毁全局定时器
--@param timerKey 定时器唯一标识
function Timer.removeTimer(timerKey)
    assert(timerKey)
    _timerGroup.removes[timerKey] = true
end

--[[
说明：
    由于CCNode类中并没有导出schedule相关接口到lua里（虽然有scheduleUpdateWithPriorityLua
    函数可以在lua中使用，但这个接口的回调触发是固定的，每帧都会触发，用的时候会有
    性能问题），所以在不修改cocos源码的情况下，基于这套定时器机制我们需要自己掌控
    CCNode对象的生命周期，在对象销毁的时候主动把挂在它上面的所有定时器都清理掉。
]]

--为Node添加定时器，Node销毁则自动销毁
--@param node 节点控件
--@param callback 定时器触发回调，函数原型：function callback(dt, timerKey, node)
--@param interval 定时器触发时间间隔，单位秒
--@param timerKey 定时器唯一标识，传nil意味着会随机生成一个定时器标识
--@return 返回定时器唯一标识
function Timer.addTimerForNode(node, callback, interval, timerKey)
    -- if not _globalTimerId then
    --     _timerOpen()
    -- end

    if not node._lifeRegisteredForTimer then
        local function lifeCallback(event)
            if event == "cleanup" then
                Timer.removeAllTimerForNode(node)
            end
        end
        node._lifeRegisteredForTimer = true
        node:registerScriptHandler(lifeCallback)
    end

    if not node._timerGroup then
        node._timerGroup =
        {
            --{k -> {callback, interval, elapse}}
            handlers = {},
            --{k, true}
            removes = {},
            --随机定时器索引
            randomTimerId = 0,
        }
        table.insert(_timerNodes, 1, node)
    end
    timerKey = timerKey or _getRandomTimerKey(node)
    node._timerGroup.handlers[timerKey] = {callback, interval or 0, 0}

    --正在移除则清掉
    node._timerGroup.removes[timerKey] = nil
    return timerKey
end

--为Node添加定时器，触发一次后自动销毁、Node销毁则自动销毁
--@param node 节点控件
--@param callback 定时器触发回调，函数原型：function callback(dt, timerKey, node)
--@param interval 定时器触发时间间隔，单位秒
--@param timerKey 定时器唯一标识，传nil意味着会随机生成一个定时器标识
--@return 返回定时器唯一标识
function Timer.addTimerOnceForNode(node, callback, interval, timerKey)
    local function _callback(dt, key, ...)
        node:removeTimer(key)
        callback(dt, key, ...)
    end
    return Timer.addTimerForNode(node, _callback, interval, timerKey)
end

--销毁Node定时器
--@param node 节点控件
--@param timerKey 定时器唯一标识
function Timer.removeTimerForNode(node, timerKey)
    local group = node._timerGroup
    if group then
        group.removes[timerKey] = true
    end
end

--移除节点上的所有定时器
--@param node 节点控件
function Timer.removeAllTimerForNode(node)
    local group = node._timerGroup
    if group then
        for k in pairs(group.handlers) do
            group.removes[k] = true
        end
    end
end

--清理所有定时器
function Timer.clearAll()
    --清理全局定时器
    for k in pairs(_timerGroup.handlers) do
        _timerGroup.removes[k] = true
    end
    _timerGroup.handlers = {}
    _timerGroup.removes = {}
    _timerGroup.randomTimerId = 0

    --清理所有节点定时器
    for _,node in ipairs(_timerNodes) do
        local group = node._timerGroup
        if group then
            for k in pairs(group.handlers) do
                group.removes[k] = true
            end
            node._timerGroup = nil
        end
    end

    --关闭定时器
    _timerClose()
end

--返回Timer
return function()
    return Timer, _timerFunc
end
