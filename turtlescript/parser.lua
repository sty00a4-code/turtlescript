local ast = require " turtlescript.ast"

local Parser = {
    mt = {
        __name = "parser"
    }
}
---@param tokens Token[]
---@return Parser
function Parser.new(tokens)
    ---@class Parser
    return setmetatable({
        tokens = tokens,

        consume = Parser.consume,
        get = Parser.get,

        parse = Parser.parse,
        dataStat = Parser.dataStat,

        block = Parser.block,
        stat = Parser.stat,

        expr = Parser.expr,
        logic = Parser.logic,
        comp = Parser.comp,
        arith = Parser.arith,
        term = Parser.term,
        pow = Parser.pow,

        factor = Parser.factor,
        neg = Parser.neg,

        value = Parser.value,
        call = Parser.call,
        atom = Parser.atom,
    }, Parser.mt)
end
---@param self Parser
function Parser:consume()
    return table.remove(self.tokens, 1)
end
---@param self Parser
function Parser:get()
    return self.tokens[1]
end

return {
    Parser = Parser,
    ---@param path string
    ---@param tokens Token[]
    parse = function (path, tokens)
        local parser = Parser.new(tokens)
        return parser.parse()
    end
}