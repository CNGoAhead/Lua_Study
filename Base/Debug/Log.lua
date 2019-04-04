local Log = Class('Log')
require('lfs')

function Log:Log(fileName)
    self:initFiles(fileName)
end

local function closeFile(pfile)
    if pfile then
        pfile:close()
    end
end

function Log:initFiles(fileName)
    local cpath = lfs.currentdir()
    self._time = os.time()
    self._fileName = (fileName or 'Default')
    local atb = lfs.attributes(cpath .. '/' .. self._fileName)
    if not atb or atb.mode ~= 'directory' then
        lfs.mkdir(cpath .. '/' .. self._fileName)
    end
    local date = string.gsub(os.date('%x', self._time), '/', '-')
    atb = lfs.attributes(cpath .. '/' .. self._fileName .. '/' .. date)
    if not atb or atb.mode ~= 'directory' then
        lfs.mkdir(cpath .. '/' .. self._fileName .. '/' .. date)
    end
    closeFile(self._fileError)
    closeFile(self._fileWarn)
    closeFile(self._fileLog)
    self._fileError = io.open(cpath .. '/' .. self._fileName .. '/' .. date .. '/' .. 'ERROR.txt', 'a')
    self._fileWarn = io.open(cpath .. '/' .. self._fileName .. '/' .. date .. '/' .. 'WARN.txt', 'a')
    self._fileLog = io.open(cpath .. '/' .. self._fileName .. '/' .. date .. '/' .. 'LOG.txt', 'a')
end

local function composeText(...)
    local time = '----Time----:' .. os.date('%c', os.time())
    local log = {...}
    table.insert(log, 1, time)
    table.insert(log, '------------\n')
    return table.concat(log, "\n")
end

function Log:checkFiles()
    if os.date('%d', os.time()) ~= os.date('%d', self._time) then
        self:initFiles(self._fileName)
    end
end

function Log:E(...)
    self:checkFiles()
    local error = composeText(...)
    self._fileError:write(error)
    self._fileError:flush()
    return error
end

function Log:W(...)
    self:checkFiles()
    local warn = composeText(...)
    self._fileWarn:write(warn)
    self._fileWarn:flush()
    return warn
end

function Log:L(...)
    self:checkFiles()
    local log = composeText(...)
    self._fileLog:write(log)
    self._fileLog:flush()
    return log
end

return function()
    return Log
end