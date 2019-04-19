local ShaderHelper = {}

local ShaderBlender = import(".ShaderBlender")
local UniformModel = import(".UniformModel")

function ShaderHelper.addBlendShadersWithNew(node, ...)
    local shaders = {...}
    if type(shaders[1]) == "table" then
        shaders = shaders[1]
    end
    local glProgram, uniforms = ShaderBlender(shaders)
    local glProgramState = ShaderHelper.createGLProgramState(glProgram)
    node.__shaders = {
        GLProgramState = glProgramState,
        Blends = shaders
    }
    node:setGLProgramState(glProgramState)
    return UniformModel:create(glProgramState, glProgram, uniforms)
end

function ShaderHelper.addBlendShadersWithGet(node, ...)
    local shaders = {...}
    if type(shaders[1]) == "table" then
        shaders = shaders[1]
    end
    local glProgram, uniforms = ShaderBlender(shaders)
    local glProgramState = ShaderHelper.getGLProgramState(glProgram)
    node.__shaders = {
        GLProgramState = glProgramState,
        Blends = shaders
    }
    node:setGLProgramState(glProgramState)
    return UniformModel:create(glProgramState, glProgram, uniforms)
end

function ShaderHelper.addBlendShaderWithNew(node, name)
    local shaders = node.__shaders.Blends
    table.insert(shaders, name)
    ShaderHelper.addBlendShadersWithNew(node, shaders)
end

function ShaderHelper.addBlendShaderWithGet(node, name)
    local shaders = node.__shaders.Blends
    table.insert(shaders, name)
    ShaderHelper.addBlendShadersWithGet(node, shaders)
end

function ShaderHelper.removeBlendShaderWithNew(node, name)
    if not node.__shaders then
        return
    end
    for i, v in ipairs(node.__shaders.Blends) do
        if v == name then
            table.remove(node.__shaders.Blends, i)
            break
        end
    end
    local shaders = node.__shaders.Blends
    ShaderHelper.addBlendShadersWithNew(node, shaders)
end

function ShaderHelper.removeBlendShaderWithGet(node, name)
    if not node.__shaders then
        return
    end
    for i, v in ipairs(node.__shaders.Blends) do
        if v == name then
            table.remove(node.__shaders.Blends, i)
            break
        end
    end
    local shaders = node.__shaders.Blends
    ShaderHelper.addBlendShadersWithGet(node, shaders)
end

function ShaderHelper.createGLProgramState(glProgram)
    return cc.GLProgramState:create(glProgram)
end

function ShaderHelper.getGLProgramState(glProgram)
    return cc.GLProgramState:getOrCreateWithGLProgram(glProgram)
end

return ShaderHelper