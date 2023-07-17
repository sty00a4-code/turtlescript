local value = require "turtlescript.value"

local Call = {
    mt = {
        __name = "call"
    }
}
---@param type string
---@param pointer integer
---@param args Value[]
---@return Call
function Call.new(type, pointer, args)
    ---@class Call
    return setmetatable({
        type = type,
        pointer = pointer,
        args = args,
    }, Call.mt)
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
        stack = {},
        ---@type Call[]
        callStack = {},

        push = Interpreter.push,
        pop = Interpreter.pop,
        pushCall = Interpreter.pushCall,
        popCall = Interpreter.popCall,
        step = Interpreter.step,
        run = Interpreter.run,
    }, Interpreter.mt)
end