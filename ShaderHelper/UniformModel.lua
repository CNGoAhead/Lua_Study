local BaseModel = GMethod.loadScript("model.BaseModel")
local UniformModel = class("UniformModel", BaseModel)

local function convertType(type)
    if type == "sampler2D" then
        return "Texture"
    else
        return string.gsub(type, string.sub(type, 1, 1), string.upper(string.sub(type, 1, 1)), 1)
    end
end

local function setUniformValue(state, type, id, value)
    if id ~= -1 then
        local setFunc = state["setUniform" .. convertType(type)]
        if setFunc then
            setFunc(state, id, value)
        else
            print("----WARN----:this type is not supported now!!! type = ", type)
        end
    end
end

function UniformModel:onCreate(state, program, uniforms)
    self._glProgramState = state
    self._glProgram = program
    for _, v in ipairs(uniforms) do
        self:property(
            self.propNGS(
                v[2],
                {
                    type = v[1],
                    name = v[2],
                    id = gl.getUniformLocation(self._glProgram:getProgram(), v[2]),
                    value = nil
                },
                function()
                    return self.propget(v[2]).value
                end,
                function(value)
                    local p = self.propget(v[2])
                    p.value = value
                    setUniformValue(self._glProgramState, p.type, p.id, p.value)
                end
            )
        )
    end
end

return UniformModel