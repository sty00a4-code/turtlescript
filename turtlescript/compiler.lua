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
        scopePtr = 0,

        gotoVar = Compiler.gotoVar,
        gotoConst = Compiler.gotoConst,
        gotoProc = Compiler.gotoProc,
        gotoFunc = Compiler.gotoFunc,
        getCode = Compiler.getCode,
        getScope = Compiler.getScope,
        newScope = Compiler.newScope,
        upScope = Compiler.upScope,
        downScope = Compiler.downScope,
        getLocal = Compiler.getLocal,
        newAddr = Compiler.newAddr,
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
---@return ScopePreset?
function Compiler:getScope()
    return self.program.scopes[self.scopePtr]
end
---@param self Compiler
function Compiler:newScope()
    local parent = self.program.scopes[#self.program.scopes]
    local scope = code.ScopePreset.new({}, parent, {})
    table.insert(self.program.scopes, scope)
    if parent then
        table.insert(parent.children, scope)
    end
end
---@param self Compiler
function Compiler:upScope()
    self.scopePtr = self.scopePtr + 1
end
---@param self Compiler
function Compiler:downScope()
    self.scopePtr = self.scopePtr - 1
end
---@param self Compiler
---@param ident string
---@return integer?
function Compiler:getLocal(ident)
    local currentScope = self:getScope()
    if currentScope then
        return currentScope:getLocal(ident)
    end
end
---@param self Compiler
---@return integer?
function Compiler:newAddr()
    if self.ptrType == "proc" then
        local proc = self.program.procedures[self.procPtr]
        proc.memory = proc.memory + 1
        return proc.memory
    elseif self.ptrType == "func" then
        local func = self.program.functions[self.funcPtr]
        func.memory = func.memory + 1
        return func.memory
    end
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
        local ident, expr = node.ident, node.expr
        if self.names.varialbes[ident.ident] then
            return nil, ("duplicate definition of variable %q"):format(ident.ident)
        end
        self.names.varialbes[ident.ident] = #self.program.variables
        self:gotoVar(#self.program.variables)
        ---@diagnostic disable-next-line: param-type-mismatch
        table.insert(self.program.variables, code.Variable.new(ident.ident, {}))
        ---@diagnostic disable-next-line: param-type-mismatch
        return self:compileNode(expr)
    elseif node.type == "dataStat.constant" then
        local ident, expr = node.ident, node.expr
        if self.names.constants[ident.ident] then
            return nil, ("duplicate definition of constant %q"):format(ident.ident)
        end
        self.names.constants[ident.ident] = #self.program.constants
        self:gotoConst(#self.program.constants)
        ---@diagnostic disable-next-line: param-type-mismatch
        table.insert(self.program.constants, code.Constant.new(ident.ident, {}))
        ---@diagnostic disable-next-line: param-type-mismatch
        return self:compileNode(expr)
    elseif node.type == "dataStat.procedure" then
        local ident, params, collect, body = node.ident, node.params, node.collect, node.body
        if self.names.procedures[ident.ident] then
            return nil, ("duplicate definition of procedure %q"):format(ident.ident)
        end
        self.names.procedures[ident.ident] = #self.program.procedures
        self:gotoProc(#self.program.procedures)
        local params = {}
        for _, ident in ipairs(params) do
            table.insert(params, ident.ident)
        end
        ---@diagnostic disable-next-line: param-type-mismatch
        table.insert(self.program.procedures, code.Procedure.new(ident.ident, params, {}))
        if type(body) == "table" then
            return self:compileBody(body)
        else
            ---@diagnostic disable-next-line: param-type-mismatch
            return self:compileNode(body)
        end
    elseif node.type == "dataStat.function" then
        local ident, params, collect, body = node.ident, node.params, node.collect, node.body
        if self.names.functions[ident.ident] then
            return nil, ("duplicate definition of function %q"):format(ident.ident), ident.pos
        end
        self.names.functions[ident.ident] = #self.program.functions
        self:gotoFunc(#self.program.functions)
        local params = {}
        for _, ident in ipairs(params) do
            table.insert(params, ident.ident)
        end
        ---@diagnostic disable-next-line: param-type-mismatch
        table.insert(self.program.functions, code.Function.new(ident.ident, params, {}))
        if type(body) == "table" then
            return self:compileBody(body)
        else
            ---@diagnostic disable-next-line: param-type-mismatch
            return self:compileNode(body)
        end
    elseif node.type == "stat.do" then
        local ident, args = node.ident, node.args
        local procPtr = self.names.procedures[ident.ident]
        if not procPtr then
            return nil, ("no procedure named %q"):format(ident.ident), ident.pos
        end
        ---todo! arguments
        self:write(code.ByteCode.GotoProc, procPtr)
    elseif node.type == "stat.call" then
        local ident, args = node.ident, node.args
        local luaPtr = #self.program.lua
        for idx, luaIdent in ipairs(self.program.lua) do
            if ident.ident == luaIdent then
                luaPtr = idx
                break
            end
        end
        ---@diagnostic disable-next-line: assign-type-mismatch
        self.program.lua[luaPtr] = ident.ident
        ---todo! arguments
        self:write(code.ByteCode.CallLua, luaPtr)
    elseif node.type == "stat.local" then
        local scope = self.program.scopes[self.scopePtr]
        local ident, expr = node.ident, node.expr
        if scope then
            local addr = self:newAddr()
            if addr then
                scope.locals[ident.ident] = addr
                if expr then
                    self:compileNode(expr)
                    self:write(code.ByteCode.SetLocal, addr)
                end
            end
        else
            error "no scope"
        end
    elseif node.type == "stat.assign" then
        local scope = self.program.scopes[self.scopePtr]
        local ident, expr = node.ident, node.expr
        ---@diagnostic disable-next-line: param-type-mismatch
        self:compileNode(expr)
        local addr = scope:getLocal(ident.ident)
        if addr then
            self:write(code.ByteCode.SetLocal, addr)
            return
        end
        return nil, ("cannot find %q in this scope"):format(ident.ident), ident.pos

    elseif node.type == "stat.return" then
        local expr = node.expr
        if expr then
            self:compileNode(expr)
        end
        self:write(code.ByteCode.Return)
    end
end

return {
    Compiler = Compiler
}