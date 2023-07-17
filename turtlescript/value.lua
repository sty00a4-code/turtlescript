local Value = {
    mt = {
        __name = "value",
        __tostring = function(self)
            return tostring(self.value)
        end
    }
}
---@param value any
---@param typ string
---@return Value
function Value.new(value, typ)
    ---@class Value
    return setmetatable({
        type = typ or type(value),
        value = value,
        unwrap = Value.unwrap
    }, Value.mt)
end
---@param self Value
function Value:unwrap()
    return self.value
end
---@param self Value
function Value:type()
    return self.type
end
---@param self Value
function Value:innerType()
    return type(self.value)
end