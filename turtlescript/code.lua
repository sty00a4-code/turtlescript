---@alias ByteCode integer
local ByteCode = {
    None = 0x0,
    Halt = 0x1,
    Jump = 0x2, -- addr
    JumpIf = 0x3, -- addr
    JumpIfNot = 0x4, -- addr

    GotoProc = 0x10, -- procAddr
    GotoFunc = 0x11, -- funcAddr
    CallLua = 0x12, -- luaAddr
    Return = 0x13, -- amount

    Nil = 0x20,
    Number = 0x21, -- number
    String = 0x22, -- stringAddr
    Bool = 0x23, -- boolean

    Var = 0x30, -- variableAddr
    Const = 0x31, -- constantAddr
    Param = 0x32, -- parameterAddr
    Local = 0x33, -- localAddr
    SetVar = 0x34, -- variableAddr
    SetParam = 0x36, -- parameterAddr
    SetLocal = 0x35, -- localAddr

    Add = 0x40,
    Sub = 0x41,
    Mul = 0x42,
    Div = 0x43,
    Pow = 0x44,
    Mod = 0x45,
    EQ = 0x46,
    NE = 0x47,
    LT = 0x48,
    GT = 0x49,
    LE = 0x4a,
    GE = 0x4b,
    And = 0x4c,
    Or = 0x4d,
    Neg = 0x4e,
    Not = 0x4f,

    PushScope = 0x100, -- scopeAddr
    PopScope = 0x101,
}

local Program = {
    mt = {
        __name = "program"
    }
}
function Program.new()
    ---@class Program
    return setmetatable({
        ---@type string[]
        strings = {},
        ---@type string[]
        lua = {},

        ---@type Procedure[]
        procedures = {},
        ---@type Function[]
        functions = {},
        ---@type Variable[]
        variables = {},
        ---@type Constant[]
        constants = {},
        ---@type Scope[]
        scopes = {},
    }, Program.mt)
end

local Parameter = {
    mt = {
        __name = "parameter"
    }
}
---@param ident string
---@return Parameter
function Parameter.new(ident)
    ---@class Parameter
    return setmetatable({
        ident = ident,
    }, Parameter.mt)
end
local Procedure = {
    mt = {
        __name = "procedure"
    }
}
---@param ident string
---@param parameters Parameter[]
---@param code ByteCode[]
---@return Procedure
function Procedure.new(ident, parameters, code)
    ---@class Procedure
    return setmetatable({
        ident = ident,
        parameters = parameters,
        code = code,
    }, Procedure.mt)
end
local Function = {
    mt = {
        __name = "function"
    }
}
---@param ident string
---@param parameters Parameter[]
---@param code ByteCode[]
---@return Function
function Function.new(ident, parameters, code)
    ---@class Function
    return setmetatable({
        ident = ident,
        parameters = parameters,
        code = code,
    }, Function.mt)
end

local Variable = {
    mt = {
        __name = "variable"
    }
}
---@param ident string
---@param code ByteCode[]
---@return Variable
function Variable.new(ident, code)
    ---@class Variable
    return setmetatable({
        ident = ident,
        code = code,
    }, Variable.mt)
end
local Constant = {
    mt = {
        __name = "constant"
    }
}
---@param ident string
---@param code ByteCode[]
---@return Constant
function Constant.new(ident, code)
    ---@class Constant
    return setmetatable({
        ident = ident,
        code = code,
    }, Constant.mt)
end

local Scope = {
    mt = {
        __name = "scope"
    }
}
---@param locals Variable[]
---@param parameters Parameter[]
---@param globals table<integer, Variable|Constant>
---@param parent Scope?
---@param children Scope[]
---@return Scope
function Scope.new(locals, parameters, globals, parent, children)
    ---@class Scope
    return setmetatable({
        locals = locals,
        parameters = parameters,
        globals = globals,
        parent = parent,
        children = children,
    }, Scope.mt)
end

return {
    ByteCode = ByteCode,
    Program = Program,
    Parameter = Parameter,
    Procedure = Procedure,
    Function = Function,
    Variable = Variable,
    Constant = Constant,
    Scope = Scope,
}