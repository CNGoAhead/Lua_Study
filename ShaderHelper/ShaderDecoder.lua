local function ShaderDecoder(name)
    io.input("./res/shaders/" .. name .. ".fsh")
    local content = io.read("*a")
    io.close()

    local uniforms = string.match(content, "//uniform(.*)//uniform") or ""
    local functions = string.match(content, "//function(.*)//function") or ""
    local main = string.match(content, "//main(.*)//main") or ""
    return {
        uniforms = uniforms,
        functions = functions,
        main = main
    }
end

return ShaderDecoder