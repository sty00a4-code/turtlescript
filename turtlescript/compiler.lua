local code = require "turtlescript.code"

local Compiler = {
    mt = {
        __name = "compiler"
    }
}
---@param path string
---@return Compiler
function Compiler.new(path)
    ---@class Compiler
    return setmetatable({
        path = path,
        program = code.Program.new(),
        names = {
            ---@type table<string, integer>
            varialbes = {},
            ---@type table<string, integer>
            constants = {},
            ---@type table<string, integer>
            procedures = {},
            ---@type table<string, integer>
            functions = {},
        },
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
        getCode = Compiler.getCode,
        write = Compiler.write,
        overwrite = Compiler.overwrite,
        compile = Compiler.compile,
        compileBody = Compiler.compileBody,
        compileNode = Compiler.compileNode,
    }, Compiler.mt)
end
---@param self Compiler
---@param ptr integer
function Compiler:gotoVar(ptr)
    self.ptrType = "var"
    self.varPtr = ptr
end
---@param self Compiler
---@param ptr integer
function Compiler:gotoConst(ptr)
    self.ptrType = "const"
    self.constPtr = ptr
end
---@param self Compiler
---@param ptr integer
function Compiler:gotoProc(ptr)
    self.ptrType = "proc"
    self.procPtr = ptr
end
---@param self Compiler
---@param ptr integer
function Compiler:gotoFunc(ptr)
    self.ptrType = "func"
    self.funcPtr = ptr
end
---@param self Compiler
---@return Code?
function Compiler:getCode()
    local code
    if self.ptrType == "proc" then
        local proc = self.program.procedures[self.procPtr]
        if proc then
            code = proc.code
        end
    elseif self.ptrType == "func" then
        local func = self.program.functions[self.funcPtr]
        if func then
            code = func.code
        end
    elseif self.ptrType == "var" then
        local var = self.program.variables[self.varPtr]
        if var then
            code = var.code
        end
    elseif self.ptrType == "const" then
        local const = self.program.constants[self.constPtr]
        if const then
            code = const.code
        end
    end
    return code
end
---@param self Compiler
---@param instr ByteCode
---@param arg1 integer?
function Compiler:write(instr, arg1)
    arg1 = arg1 or 0
    local code = self:getCode()
    if code then
        table.insert(code, instr)
        table.insert(code, arg1)
    end
end
---@param self Compiler
---@param pos integer
---@param instr ByteCode?
---@param arg1 integer?
function Compiler:overwrite(pos, instr, arg1)
    instr = instr or 0
    arg1 = arg1 or 0
    local code = self:getCode()
    if code then
        code[pos] = instr
        code[pos + 1] = arg1
    end
end
---@param self Compiler
---@param program DataStat[]
function Compiler:compile(program)
    for _, stat in ipairs(program) do
        self:compileNode(stat)
    end
end
---@param self Compiler
---@param body Stat[]
function Compiler:compileBody(body)
    for _, stat in ipairs(body) do
        self:compileNode(stat)
    end
end
---@param self Compiler
---@param node DataStat|Stat|Expr|Atom
function Compiler:compileNode(node)
    if node.type == "dataStat.variable" then
        if self.names.varialbes[node.ident] then
            return nil, ("duplicate definition of variable %q"):format(node.ident)
        end
        self.names.varialbes[node.ident] = #self.program.variables
        self:gotoVar(#self.program.variables)
        ---@diagnostic disable-next-line: param-type-mismatch
        table.insert(self.program.variables, code.Variable.new(node.ident, {}))
        return self:compileNode(node.expr)
    elseif node.type == "dataStat.constant" then
        if self.names.constants[node.ident] then
            return nil, ("duplicate definition of constant %q"):format(node.ident)
        end
        self.names.constants[node.ident] = #self.program.constants
        self:gotoConst(#self.program.constants)
        ---@diagnostic disable-next-line: param-type-mismatch
        table.insert(self.program.constants, code.Constant.new(node.ident, {}))
        return self:compileNode(node.expr)
    elseif node.type == "dataStat.procedure" then
        if self.names.procedures[node.ident] then
            return nil, ("duplicate definition of procedure %q"):format(node.ident)
        end
        self.names.procedures[node.ident] = #self.program.procedures
        self:gotoProc(#self.program.procedures)
        local params = {}
        for _, ident in ipairs(node.params) do
            table.insert(params, ident.ident)
        end
        ---@diagnostic disable-next-line: param-type-mismatch
        table.insert(self.program.procedures, code.Procedure.new(node.ident, params, {}))
        return self:compileBody(node.body)
    elseif node.type == "dataStat.function" then
        if self.names.functions[node.ident] then
            return nil, ("duplicate definition of function %q"):format(node.ident)
        end
        self.names.functions[node.ident] = #self.program.functions
        self:gotoFunc(#self.program.functions)
        local params = {}
        for _, ident in ipairs(node.params) do
            table.insert(params, ident.ident)
        end
        ---@diagnostic disable-next-line: param-type-mismatch
        table.insert(self.program.functions, code.Function.new(node.ident, params, {}))
        return self:compileBody(node.body)
    elseif node.type == "stat.do" then
        local procPtr = self.names.procedures[node.ident]
        if not procPtr then
            return nil, ("no procedure named %q"):format(node.ident)
        end
        ---todo! arguments
        self:write(code.ByteCode.GotoProc, procPtr)
    elseif node.type == "stat.call" then
        local luaPtr = #self.program.lua
        for idx, ident in ipairs(self.program.lua) do
            if node.ident == ident then
                luaPtr = idx
                break
            end
        end
        ---@diagnostic disable-next-line: assign-type-mismatch
        self.program.lua[luaPtr] = node.ident
        ---todo! arguments
        self:write(code.ByteCode.CallLua, luaPtr)
    end
end

return {
    Compiler = Compiler
}