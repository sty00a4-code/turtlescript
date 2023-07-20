local code = require "turtlescript.code"
local ByteCode = code.ByteCode
local value = require "turtlescript.value"

local Call = {
    mt = {
        __name = "call"
    }
}
---@param type "proc"|"func"|"var"|"const"
---@param codePointer integer
---@param pointer integer
---@param args Value[]
---@return Call
function Call.new(type, codePointer, pointer, args)
    ---@class Call
    return setmetatable({
        type = type,
        codePointer = codePointer,
        pointer = pointer,
        args = args,
    }, Call.mt)
end
local Scope = {
    mt = {
        __name = "scope"
    }
}
---@param locals string[]
---@return Scope
function Scope.new(locals)
    local values = {}
    for i = 1, #locals do
        table.insert(values, value.Value.new(nil))
    end
    ---@class Scope
    return setmetatable({
        locals = locals,
        values = values,
    }, Scope.mt)
end

local Interpreter = {
    mt = {
        __name = "interpreter"
    }
}
---@param program Program
---@return Interpreter
function Interpreter.new(program)
    ---@class Interpreter
    return setmetatable({
        program = program,
        ---@type Value[]
        variables = {},
        ---@type Value[]
        constants = {},
        ---@type Value[]
        stack = {},
        ---@type Call[]
        callStack = {},
        ---@type Scope[]
        scopeStack = {},

        get = Interpreter.get,
        advance = Interpreter.advance,
        next = Interpreter.next,
        var = Interpreter.var,
        const = Interpreter.const,
        push = Interpreter.push,
        pop = Interpreter.pop,
        getCall = Interpreter.getCall,
        pushCall = Interpreter.pushCall,
        popCall = Interpreter.popCall,
        getScope = Interpreter.getScope,
        getLocal = Interpreter.getLocal,
        pushScope = Interpreter.pushScope,
        popScope = Interpreter.popScope,
        step = Interpreter.step,
        run = Interpreter.run,
    }, Interpreter.mt)
end
---@param self Interpreter
---@return ByteCode?, string?
function Interpreter:get()
    local call = self:getCall()
    if call then
        if call.type == "proc" then
            if self.program.procedures[call.codePointer] then
                return self.program.procedures[call.codePointer][call.pointer]
            else
                return nil, "no procedure"
            end
        elseif call.type == "func" then
            if self.program.functions[call.codePointer] then
                return self.program.functions[call.codePointer][call.pointer]
            else
                return nil, "no function"
            end
        elseif call.type == "var" then
            if self.program.variables[call.codePointer] then
                return self.program.variables[call.codePointer][call.pointer]
            else
                return nil, "no variable"
            end
        elseif call.type == "const" then
            if self.program.constants[call.codePointer] then
                return self.program.constants[call.codePointer][call.pointer]
            else
                return nil, "no variable"
            end
        else
            return nil, "invalid call type"
        end
    end
    return nil, "no call"
end
---@param self Interpreter
---@return boolean
function Interpreter:advance()
    local call = self:getCall()
    if call then
        call.pointer = call.pointer + 1
        return true
    else
        return false
    end
end
---@param self Interpreter
---@return ByteCode, ByteCode
function Interpreter:next()
    local instr = self:get()
    self:advance()
    local addr = self:get()
    self:advance()
    return instr or ByteCode.None, addr or 0
end

---@param self Interpreter
---@param idx integer
---@return Value?
function Interpreter:var(idx)
    return self.variables[idx]
end
---@param self Interpreter
---@param idx integer
---@return Value?
function Interpreter:const(idx)
    return self.constants[idx]
end
---@param self Interpreter
---@param value Value
function Interpreter:push(value)
    table.insert(self.stack, value)
end
---@param self Interpreter
---@return Value?
function Interpreter:pop()
    table.remove(self.stack)
end

---@param self Interpreter
---@return Call?
function Interpreter:getCall()
    return self.callStack[#self.callStack]
end
---@param self Interpreter
---@param call Call
function Interpreter:pushCall(call)
    table.insert(self.callStack, call)
end
---@param self Interpreter
---@return Call?
function Interpreter:popCall()
    table.remove(self.callStack)
end

---@param self Interpreter
---@return Call?
function Interpreter:getScope()
    return self.callStack[#self.callStack]
end
---@param self Interpreter
---@param call Call
function Interpreter:pushScope(call)
    table.insert(self.callStack, call)
end
---@param self Interpreter
---@return Call?
function Interpreter:popScope()
    table.remove(self.callStack)
end

---@param self Interpreter
---@return boolean, string?
function Interpreter:step()
    local instr, addr = self:next()
    if instr == ByteCode.None then
        return true
    elseif instr == ByteCode.Halt then
        return false
    elseif instr == ByteCode.Jump then
        local call = self:getCall()
        if call then
            call.pointer = addr
            return true
        else
            return false, "no call"
        end
    elseif instr == ByteCode.JumpIf then
        local cond = self:pop()
        if not cond then
            return false, "stack underflow"
        end
        local call = self:getCall()
        if call then
            if cond:unwrap() then
                call.pointer = addr
            end
            return true
        else
            return false, "no call"
        end
    elseif instr == ByteCode.JumpIfNot then
        local cond = self:pop()
        if not cond then
            return false, "stack underflow"
        end
        local call = self:getCall()
        if call then
            if not cond:unwrap() then
                call.pointer = addr
            end
            return true
        else
            return false, "no call"
        end

    elseif instr == ByteCode.GotoProc then
        local proc = self.program.procedures[addr]
        local args = {}
        for i, parameter in ipairs(proc.parameters) do
            args[i] = self:pop()
            ---todo! when scopes are in: set the parameter
        end
        local call = Call.new("proc", addr, 1, args)
        self:pushCall(call)
        return true
    elseif instr == ByteCode.GotoFunc then
        local func = self.program.functions[addr]
        local args = {}
        for i, parameter in ipairs(func.parameters) do
            args[i] = self:pop()
            ---todo! when scopes are in: set the parameter
        end
        local call = Call.new("func", addr, 1, args)
        self:pushCall(call)
        return true
    elseif instr == ByteCode.CallLua then
        local name = self.program.lua[addr]
        local func = _ENV[name] --- todo! sandboxed environment as self.environment
        local args = {}
        for i, parameter in ipairs(func.parameters) do
            args[i] = self:pop()
            ---todo! when scopes are in: set the parameter
        end
        ---@type any[]
        local res = { pcall(func, table.unpack(args)) }
        ---@type boolean
        local success = table.remove(res, 1)
        if success then
            for _, v in ipairs(res) do
                self:push(value.Value.new(value))
            end
            return true
        else
            return false, res[1]
        end
    elseif instr == ByteCode.Return then
        local call = self:popCall()
        if call then

            return true
        else
            return false, "no call"
        end

    elseif instr == ByteCode.Nil then
        self:push(value.Value.new(nil))
        return true
    elseif instr == ByteCode.Number then
        self:push(value.Value.new(addr))
        return true
    elseif instr == ByteCode.String then
        local s = self.program.strings[addr]
        if not s then
            return false, "no string"
        end
        self:push(value.Value.new(s))
        return true
    elseif instr == ByteCode.Bool then
        self:push(value.Value.new(addr ~= 0))
        return true

    elseif instr == ByteCode.Var then
        local value = self:var(addr)
        if not value then
            return false, "no variable"
        end
        self:push(value)
        return true
    elseif instr == ByteCode.Const then
        local value = self:const(addr)
        if not value then
            return false, "no variable"
        end
        self:push(value)
        return true
    elseif instr == ByteCode.Param then
        local call = self:getCall()
        if not call then
            return false, "no call"
        end
        local paramValue = call.args[addr]
        if not paramValue then
            paramValue = value.Value.new(nil)
        end
        self:push(paramValue)
        return true
    elseif instr == ByteCode.Local then
        local call = self:getCall()
        if not call then
            return false, "no call"
        end
        local paramValue = call.args[addr]
        if not paramValue then
            paramValue = value.Value.new(nil)
        end
        self:push(paramValue)
        return true

    else
        return false, "unknown instruction"
    end
end

return {
    Call = Call,
    Scope = Scope,
    Interpreter = Interpreter
}