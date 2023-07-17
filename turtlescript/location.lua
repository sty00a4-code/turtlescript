local Position = {
    mt = {
        __name = "position"
    }
}
---@param lnStart integer
---@param lnStop integer
---@param colStart integer
---@param colStop integer
---@return Position
function Position.new(lnStart, lnStop, colStart, colStop)
    ---@class Position
    return setmetatable({
        ln = {
            start = lnStart,
            stop = lnStop,
        },
        col = {
            start = colStart,
            stop = colStop,
        },
        copy = Position.copy,
        extend = Position.extend,
    }, Position.mt)
end
---@param self Position
---@return Position
function Position:copy()
    return Position.new(self.ln.start, self.ln.stop, self.col.start, self.col.stop)
end
---@param self Position
---@param other Position
function Position:extend(other)
    self.ln.stop = other.ln.stop
    self.col.stop = other.col.stop
end

return {
    Position = Position
}