local tokens = require "turtlescript.tokens"
local Token = tokens.Token
local location = require "turtlescript.location"
local Position = location.Position

local KEYWORDS = {
    -- values
    ["true"] = true,
    ["false"] = true,
    ["forward"] = true,
    ["back"] = true,
    ["left"] = true,
    ["right"] = true,
    ["up"] = true,
    ["down"] = true,

    -- call value
    ["fuel"] = true,
    ["selected"] = true,
    ["item_count"] = true,
    ["item_space"] = true,

    -- general
    ["end"] = true,
    ["then"] = true,
    ["to"] = true,
    ["do"] = true,
    ["call"] = true,

    -- comparison
    ["and"] = true,
    ["or"] = true,
    ["not"] = true,
    
    -- control flow
    ["if"] = true,
    ["else"] = true,
    ["repeat"] = true,
    ["while"] = true,
    ["for"] = true,
    ["each"] = true,
    ["pair"] = true,
    ["in"] = true,

    -- data
    ["procedure"] = true,
    ["function"] = true,
    ["variable"] = true,
    ["constant"] = true,
    ["local"] = true,

    -- turtle actions
    ["move"] = true,
    ["turn"] = true,
    ["place"] = true,
    ["dig"] = true,
    ["attack"] = true,
    ["select"] = true,
    ["drop"] = true,
    ["suck"] = true,
    ["equip"] = true,
    ["refuel"] = true,
    ["transfer"] = true,
    
    -- turtle functions
    ["detect"] = true,
    ["inspect"] = true,
    ["compare"] = true,
    ["item_detail"] = true,
}
local SYMBOLS = {
    -- general
    "(", ")", "[", "]", "{", "}",
    "=", ",", ":",
    -- comparison
    "==", "!=", "<=", ">=", "<", ">",
    -- assign
    "+=", "-=", "*=", "/=",
    -- arithmetic
    "+", "-", "*", "/", "%", "^"
}
---@alias AssignOperator "="|"+="|"-="|"*="|"/="
---@alias BinaryOperator "+"|"-"|"*"|"/"|"%"|"^"|"=="|"!="|"<="|">="|"<"|">"|"and"|"or"
---@alias UnaryOperator "-"|"not"
local function symbolMatch(symbol)
    local match, matches = nil, 0
    for _, s in ipairs(SYMBOLS) do
        if s == symbol then
            match = s
        elseif s:sub(1, #symbol) == symbol then
            matches = matches + 1
        end
    end
    return match, matches
end

local Lexer = {
    mt = {
        __name = "lexer"
    }
}
---@param text string
---@return Lexer
function Lexer.new(text)
    ---@class Lexer
    return setmetatable({
        text = text, tokens = {},
        idx = 1, col = 1, ln = 1,

        get = Lexer.get, pos = Lexer.pos, advance = Lexer.advance,
        whitespace = Lexer.whitespace, newline = Lexer.newline,
        number = Lexer.number, symbol = Lexer.symbol, word = Lexer.word,
        next = Lexer.next, lex = Lexer.lex
    }, Lexer.mt)
end
---@param self Lexer
---@return string
function Lexer:get()
    return self.text:sub(self.idx, self.idx)
end
---@param self Lexer
---@return Position
function Lexer:pos()
    return Position.new(self.ln, self.ln, self.col, self.col)
end
---@param self Lexer
function Lexer:advance()
    if self:get() == "\n" then
        self.ln = self.ln + 1
        self.col = 1
    else
        self.col = self.col + 1
    end
    self.idx = self.idx + 1
end
---@param self Lexer
---@return boolean
function Lexer:whitespace()
    if #self:get() == 0 then return false end
    return self:get() == " " or self:get() == "\t" or self:get() == "\r"
end
---@param self Lexer
---@return boolean
function Lexer:newline()
    if #self:get() == 0 then return false end
    return self:get() == "\n"
end
---@param self Lexer
---@return boolean
function Lexer:number()
    if #self:get() == 0 then return false end
    local byte = string.byte(self:get(), 1, 1)
    return byte >= string.byte("0", 1, 1) and byte <= string.byte("9", 1, 1)
end
---@param self Lexer
---@param prefix string?
---@return boolean
function Lexer:symbol(prefix)
    if #self:get() == 0 then return false end
    prefix = prefix or ""
    local c = prefix..self:get()
    for _, s in ipairs(SYMBOLS) do
        if s:sub(1, #c) == c then
            return true
        end
    end
    return false
end
---@param self Lexer
---@return boolean
function Lexer:word()
    if #self:get() == 0 then return false end
    local c = self:get()
    return #{c:match("%w")} > 0
end
---@param self Lexer
function Lexer:next()
    while self:whitespace() do
        self:advance()
    end
    local c = self:get()
    if #c == 0 then return end
    local pos = self:pos()
    if self:newline() then
        self:advance()
        local count = 1
        while self:newline() do
            pos:extend(self:pos())
            self:advance()
            count = count + 1
        end
        return Token.new("newline", count, pos)
    elseif self:symbol() then
        self:advance()
        local symbol = c
        while self:symbol(symbol) do
            local match, matches = symbolMatch(symbol)
            if match and matches == 0 then break end
            symbol = symbol .. self:get()
            pos:extend(self:pos())
            self:advance()
        end
        local match = symbolMatch(symbol)
        if not match then
            return nil, "invalid symbol '"..symbol.."'", pos
        end
        return Token.new("symbol", symbol, pos)
    elseif c == '"' or c == "'" then
        self:advance()
        local endChar = c
        local string = ""
        while self:get() do
            local c = self:get() if #c == 0 then break end
            if c == endChar then break end
            string = string..c
            self:advance()
        end
        if self:get() ~= endChar then
            return nil, "unclosed string", pos
        end
        pos:extend(self:pos())
        self:advance()
        return Token.new("string", string, pos)
    elseif self:number() then
        self:advance()
        local number = c
        while self:number() do
            number = number .. self:get()
            pos:extend(self:pos())
            self:advance()
        end
        return Token.new("number", tonumber(number), pos)
    elseif self:word() then
        self:advance()
        local word = c
        while self:word() or self:number() do
            word = word .. self:get()
            pos:extend(self:pos())
            self:advance()
        end
        if KEYWORDS[word] then
            return Token.new("keyword", word, pos)
        else
            return Token.new("ident", word, pos)
        end
    else
        return nil, "bad character '"..c.."'", pos
    end
end
---@param self Lexer
function Lexer:lex()
    while #self:get() > 0 do
        local token, err, epos = self:next() if err then return nil, err, epos end
        if not token then break end
        table.insert(self.tokens, token)
    end
end

return {
    Lexer = Lexer,
    lex = function (path, text)
        local lexer = Lexer.new(text)
        local _, err, epos = lexer:lex() if err then return nil, err, epos end
        return lexer.tokens
    end
}