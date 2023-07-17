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
        pos = pos
    }, Token.mt)
end

return {
    Token = Token
}