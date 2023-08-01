local ast = require "turtlescript.ast"

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

        expect = Parser.expect,
        statEnd = Parser.statEnd,

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

        ident = Parser.ident
    }, Parser.mt)
end
---@param self Parser
---@return Token?
function Parser:consume()
    return table.remove(self.tokens, 1)
end
---@param self Parser
---@return Token?
function Parser:get()
    return self.tokens[1]
end
---@param self Parser
---@param kind TokenKind
---@param value any
function Parser:expect(kind, value)
    local expected = { kind = kind, value = value }
    local token = self:consume() if not token then
        return nil, "unexpected end of file"
    end
    if token.kind ~= kind then
        return nil, ("expected %s, got %s"):format(token.name(expected), token:name())
    end
    if value then
        if token.value ~= value then
            return nil, ("expected %s, got %s"):format(token.name(expected), token:name())
        end
    end
    return token
end
---@param self Parser
function Parser:statEnd()
    local token = self:consume()
    if token then
        if token.kind ~= "newline" then
            return ("expected newline, got %s"):format(token:name()), token.pos
        end
    end
end
---@param self Parser
function Parser:parse()
    ---@type DataStat[]
    local nodes = {}
    while self:get() do
        local dataStat, err, epos = self:dataStat() if err then return nil, err, epos end
        table.insert(nodes, dataStat)
    end
    return nodes
end
---@param self Parser
function Parser:dataStat()
    local kw = self:consume() if not kw then
        return nil, "unexpected end of file"
    end
    if kw.kind == "keyword" then
        if kw.value == "variable" then
            local pos = kw.pos:copy()
            local ident, err, epos = self:ident() if err then return nil, err, epos end
            if not ident then error "not working" end
            pos:extend(ident.pos)
            local token = self:consume()
            if token then
                if token.kind == "newline" then
                    return ast.DataStat.Variable.new(ident, nil, pos)
                else
                    return nil, ("expected %q or newline, got %s"):format("=", token:name())
                end
            end
            local expr, err, epos = self:expr() if err then return nil, err, epos end
            if not expr then error "not working" end
            pos:extend(expr.pos)
            return ast.DataStat.Variable.new(ident, expr, pos), self:statEnd()
        elseif kw.value == "constant" then
            local pos = kw.pos:copy()
            local ident, err, epos = self:ident() if err then return nil, err, epos end
            if not ident then error "not working" end
            local _, err, epos = self:expect("symbol", "=") if err then return nil, err, epos end
            local expr, err, epos = self:expr() if err then return nil, err, epos end
            if not expr then error "not working" end
            pos:extend(expr.pos)
            return ast.DataStat.Constant.new(ident, expr, pos), self:statEnd()
        elseif kw.value == "procedure" then
            local pos = kw.pos:copy()
            local ident, err, epos = self:ident() if err then return nil, err, epos end
            if not ident then error "not working" end
            local body, err, epos = self:block("keyword", "end") if err then return nil, err, epos end
            if not body then error "not working" end
            pos:extend(body)
            return ast.DataStat.Procedure.new(ident, {}, nil, body, pos), self:statEnd()
        end
    end
    return nil, ("unexpected %s"):format(kw:name()), kw.pos
end

---@param self Parser
---@param kind TokenKind?
---@param value string?
function Parser:block(kind, value)
    local doToken = self:get()
    if doToken then
        if doToken.kind == "keyword" and doToken.value == "do" then
            self:consume()
            local stat, err, epos = self:stat() if err then return nil, err, epos end
            if not stat then error "not working" end
            return { stat }
        end
    end
    local startToken, err, epos = self:expect("newline") if err then return nil, err, epos end
    if not startToken then error "not working" end
    local pos = startToken.pos:copy()
    ---@type Stat[]
    local nodes = {}
    while true do
        local token = self:get() if not token then
            break
        end
        if kind and value then
            if token.kind == kind and token.value == value then
                break
            end
        end
        local stat, err, epos = self:stat() if err then return nil, err, epos end
        if not stat then error "not working" end
        pos:extend(stat.pos)
        table.insert(nodes, stat)
    end
    if kind and value then
        local token = self:get()
        if token then
            if token.kind ~= kind or token.value ~= value then
                return nil, ("expected %s, got %s"):format(token.name({kind = kind, value = value}), token:name()), token.pos
            end
            self:consume()
        else
            return nil, ("expected %s, got end of file"):format(startToken.name({kind = kind, value = value}))
        end
    end
    nodes.pos = pos
    return nodes
end
---@param self Parser
function Parser:stat()
    local otherToken = self:get()
    if not otherToken then
        return nil, ("unexpected end of file")
    end
    if otherToken.kind == "ident" then
        error "todo: statement call"
    end
    local kw = self:consume()
    if not kw then
        return nil, ("unexpected end of file")
    end
    if kw.kind == "keyword" and kw.value == "local" then
        local pos = kw.pos:copy()
        local ident, err, epos = self:ident() if err then return nil, err, epos end
        if not ident then error "not working" end
        pos:extend(ident.pos)
        local token = self:consume()
        if token then
            if token.kind == "newline" then
                return ast.DataStat.Variable.new(ident, nil, pos)
            else
                return nil, ("expected %q or newline, got %s"):format("=", token:name())
            end
        end
        local expr, err, epos = self:expr() if err then return nil, err, epos end
        if not expr then error "not working" end
        pos:extend(expr.pos)
        return ast.Stat.Local.new(ident, expr, pos), self:statEnd()
    end
end

---@param self Parser
function Parser:expr()
    ---todo! expr
    local atom, err, epos = self:atom() if err then return nil, err, epos end
    if not atom then error "not working" end
    return ast.Expr.Atom.new(atom, atom.pos)
end
---@param self Parser
function Parser:atom()
    local token = self:consume() if not token then
        return nil, ("unexpected end of file")
    end
    if token.kind == "ident" then
        return ast.Atom.Ident.new(token.value, token.pos)
    elseif token.kind == "number" then
        return ast.Atom.Number.new(token.value, token.pos)
    elseif token.kind == "string" then
        return ast.Atom.String.new(token.value, token.pos)
    elseif token.kind == "symbol" and token.value == "(" then
        local expr, err, epos = self:expr() if err then return nil, err, epos end
        if not expr then error "not working" end
        local _, err, epos = self:expect("symbol", ")") if err then return nil, err, epos end
        return ast.Atom.Expr.new(expr, expr.pos)
    else
        return nil, ("unexpected %s"):format(token:name()), token.pos
    end
end
---@param self Parser
function Parser:ident()
    local ident, err, epos = self:expect("ident") if err then return nil, err, epos end
    if not ident then error "not working" end
    return ast.Atom.Ident.new(ident.value, ident.pos)
end

return {
    Parser = Parser,
    ---@param path string
    ---@param tokens Token[]
    parse = function (path, tokens)
        local parser = Parser.new(tokens)
        return parser:parse()
    end
}