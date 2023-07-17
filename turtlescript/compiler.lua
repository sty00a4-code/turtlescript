local code = require "turtlescript.code"

local Compiler = {
    mt = {
        __name = "compiler"
    }
}
function Compiler.new(path)
    return setmetatable({
        path = path,
        program = code.Program.new(),
        varPtr = 0,
        constPtr = 0,
        procPtr = 0,
        funcPtr = 0,
        ---@type "proc"|"func"|"var"|"const"|nil
        ptrType = nil,

        gotoVar = Compiler.gotoVar,
        gotoConst = Compiler.gotoConst,
        gotoProc = Compiler.gotoProc,
        gotoFunc = Compiler.gotoFunc,
        write = Compiler.write,
        overwrite = Compiler.overwrite,
        compile = Compiler.compile,
    }, Compiler.mt)
end

return {
    Compiler = Compiler
}