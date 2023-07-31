---@alias TokenKind "newline"|"ident"|"symbol"|"keyword"|"number"|"string"

local Token = {
    mt = {
        __name = "token"
    }
}
---@param kind TokenKind
---@param value any
---@param pos Position
---@return Token
function Token.new(kind, value, pos)
    ---@class Token
    return setmetatable({
        kind = kind,
        value = value,
        pos = pos,
        name = Token.name,
    }, Token.mt)
end
---@param self Token
---@return string
function Token:name()
    if self.kind == "keyword" or self.kind == "symbol" then
        return ("%q"):format(self.value)
    else
        return self.kind
    end
end

return {
    Token = Token
}