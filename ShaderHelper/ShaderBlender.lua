local GLProgramUniforms = {}

local ShaderDecoder = import(".ShaderDecoder")

local function mergeUniforms(names)
    local nt = {}
    local t = {}
    for _, v in ipairs(names) do
        table.insert(t, GLProgramUniforms[v])
    end
    for _, w in ipairs(t) do
        for _, v in pairs(w) do
            table.insert(nt, {v[1], v[2]})
        end
    end
    return nt
end

local function createBlendShaderGLProgram(shaders)
    local name = ""
    local uniforms = {}
    local functions = {}
    local mains = {}
    for _, v in ipairs(shaders) do
        local ufm
        if v == "default" then
            ufm = {
                params = "",
                func = "",
                main = "gl_FragColor = gl_FragColor * texture2D(CC_Texture0, v_texCoord);\n"
            }
        else
            ufm = ShaderDecoder(v)
        end
        name = name .. v
        table.insert(uniforms, ufm.uniforms or "")
        table.insert(functions, ufm.functions or "")
        table.insert(mains, ufm.main or "")
    end
    local glProgram = cc.GLProgramCache:getInstance():getGLProgram(name)
    if glProgram == nil then
        local vsh = "attribute vec4 a_position;\n"..
                    "attribute vec2 a_texCoord;\n"..
                    "attribute vec4 a_color;\n"..
                    "#ifdef GL_ES\n"..
                    "varying lowp vec4 v_fragmentColor;\n"..
                    "varying mediump vec2 v_texCoord;\n"..
                    "#else\n"..
                    "varying vec4 v_fragmentColor;\n"..
                    "varying vec2 v_texCoord;\n"..
                    "#endif\n"..
                    "void main()\n"..
                    "{\n"..
                        "gl_Position = CC_PMatrix * a_position;\n"..
                        "v_fragmentColor = a_color;\n"..
                        "v_texCoord = a_texCoord;\n"..
                    "}\n"
        local fsh = "#ifdef GL_ES\n"..
                    "precision lowp float;\n"..
                    "#endif\n"..
                    "varying vec4 v_fragmentColor;\n"..
                    "varying vec2 v_texCoord;\n"
        for i, v in ipairs(uniforms) do
            if not GLProgramUniforms[shaders[i]] then
                local params = {}
                for w, _ in string.gmatch(v, "uniform (.-);") do
                    local p = {}
                    for x, _ in string.gmatch(w, "(%S+)") do
                        table.insert(p, x)
                    end
                    table.insert(params, p)
                end
                GLProgramUniforms[shaders[i]] = params
            end
            fsh = fsh .. v .. "\n"
        end
        for _, v in ipairs(functions) do
            fsh = fsh .. v .. "\n"
        end
        fsh = fsh .. "void main(){\ngl_FragColor = v_fragmentColor;\n"
        for _, v in ipairs(mains) do
            fsh = fsh .. v .. "\n"
        end
        fsh = fsh .. "}\n"
        glProgram = cc.GLProgram:createWithByteArrays(vsh, fsh)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram, name)
    end
    return glProgram, mergeUniforms(shaders)
end

return createBlendShaderGLProgram