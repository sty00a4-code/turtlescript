---@alias DataStat DataStat.Variable|DataStat.Constant|DataStat.Function|DataStat.Procedure
local DataStat = {
    Variable = {
        mt = {
            __name = "dataStat.variable"
        }
    },
    Constant = {
        mt = {
            __name = "dataStat.constant"
        }
    },
    Function = {
        mt = {
            __name = "dataStat.function"
        }
    },
    Procedure = {
        mt = {
            __name = "dataStat.procedure"
        }
    },
}
---@param ident Atom.Ident
---@param expr Expr
---@param pos Position
---@return DataStat.Variable
function DataStat.Variable.new(ident, expr, pos)
    ---@class DataStat.Variable
    return setmetatable({
        type = DataStat.Variable.mt.__name,
        ident = ident,
        expr = expr,
        pos = pos
    }, DataStat.Variable.mt)
end
---@param ident Atom.Ident
---@param expr Expr
---@param pos Position
---@return DataStat.Constant
function DataStat.Constant.new(ident, expr, pos)
    ---@class DataStat.Constant
    return setmetatable({
        type = DataStat.Constant.mt.__name,
        ident = ident,
        expr = expr,
        pos = pos
    }, DataStat.Constant.mt)
end
---@param ident Atom.Ident
---@param params Atom.Ident[]
---@param collect Atom.Ident?
---@param body Expr|Block
---@param pos Position
---@return DataStat.Function
function DataStat.Function.new(ident, params, collect, body, pos)
    ---@class DataStat.Function
    return setmetatable({
        type = DataStat.Function.mt.__name,
        ident = ident,
        params = params,
        collect = collect,
        body = body,
        pos = pos
    }, DataStat.Function.mt)
end
---@param ident Atom.Ident
---@param params Atom.Ident[]
---@param collect Atom.Ident?
---@param body Block
---@param pos Position
---@return DataStat.Procedure
function DataStat.Procedure.new(ident, params, collect, body, pos)
    ---@class DataStat.Procedure
    return setmetatable({
        type = DataStat.Procedure.mt.__name,
        ident = ident,
        params = params,
        collect = collect,
        body = body,
        pos = pos
    }, DataStat.Procedure.mt)
end

---@alias Body Stat|Stat[]
---@alias Stat Stat.Do|Stat.Call|Stat.Local|Stat.Assign|Stat.If|Stat.Repeat|Stat.While|Stat.For|Stat.ForEach|Stat.ForEachPair|Stat.Return
local Stat = {
    Do = {
        mt = {
            __name = "dataStat.do"
        }
    },
    Call = {
        mt = {
            __name = "dataStat.call"
        }
    },
    Local = {
        mt = {
            __name = "dataStat.local"
        }
    },
    Assign = {
        mt = {
            __name = "dataStat.assign"
        }
    },
    If = {
        mt = {
            __name = "dataStat.if"
        }
    },
    Repeat = {
        mt = {
            __name = "dataStat.repeat"
        }
    },
    While = {
        mt = {
            __name = "dataStat.while"
        }
    },
    For = {
        mt = {
            __name = "dataStat.for"
        }
    },
    ForEach = {
        mt = {
            __name = "dataStat.forEach"
        }
    },
    ForEachPair = {
        mt = {
            __name = "dataStat.forEachPair"
        }
    },
    Return = {
        mt = {
            __name = "dataStat.return"
        }
    },
}
---@param ident Atom.Ident
---@param args Expr[]
---@return Stat.Do
function Stat.Do.new(ident, args, pos)
    ---@class Stat.Do
    return setmetatable({
        type = Stat.Do.mt.__name,
        ident = ident,
        args = args,
        pos = pos,
    }, Stat.Do.mt)
end
---@param ident Atom.Ident
---@param args Expr[]
---@return Stat.Call
function Stat.Call.new(ident, args, pos)
    ---@class Stat.Call
    return setmetatable({
        type = Stat.Call.mt.__name,
        ident = ident,
        args = args,
        pos = pos,
    }, Stat.Call.mt)
end
---@param ident Atom.Ident
---@param expr Expr?
---@return Stat.Local
function Stat.Local.new(ident, expr, pos)
    ---@class Stat.Local
    return setmetatable({
        type = Stat.Local.mt.__name,
        ident = ident,
        expr = expr,
        pos = pos,
    }, Stat.Local.mt)
end
---@param ident Atom.Ident
---@param op AssignOperator
---@param expr Expr
---@return Stat.Assign
function Stat.Assign.new(ident, op, expr, pos)
    ---@class Stat.Assign
    return setmetatable({
        type = Stat.Assign.mt.__name,
        ident = ident,
        op = op,
        expr = expr,
        pos = pos,
    }, Stat.Assign.mt)
end
---@param cond Expr
---@param case Body
---@param elseCase Body?
---@return Stat.If
function Stat.If.new(cond, case, elseCase, pos)
    ---@class Stat.If
    return setmetatable({
        type = Stat.If.mt.__name,
        cond = cond,
        case = case,
        elseCase = elseCase,
        pos = pos,
    }, Stat.If.mt)
end
---@param expr Expr
---@param body Body
---@return Stat.Repeat
function Stat.Repeat.new(expr, body, pos)
    ---@class Stat.Repeat
    return setmetatable({
        type = Stat.Repeat.mt.__name,
        expr = expr,
        body = body,
        pos = pos,
    }, Stat.Repeat.mt)
end
---@param cond Expr
---@param body Body
---@return Stat.While
function Stat.While.new(cond, body, pos)
    ---@class Stat.While
    return setmetatable({
        type = Stat.While.mt.__name,
        cond = cond,
        body = body,
        pos = pos,
    }, Stat.While.mt)
end
---@param ident Atom.Ident
---@param from Expr
---@param to Expr
---@param steps Expr?
---@param body Body
---@return Stat.For
function Stat.For.new(ident, from, to, steps, body, pos)
    ---@class Stat.For
    return setmetatable({
        type = Stat.For.mt.__name,
        ident = ident,
        from = from,
        to = to,
        steps = steps,
        body = body,
        pos = pos,
    }, Stat.For.mt)
end
---@param ident Atom.Ident
---@param iter Expr?
---@param body Body
---@return Stat.ForEach
function Stat.ForEach.new(ident, iter, body, pos)
    ---@class Stat.ForEach
    return setmetatable({
        type = Stat.ForEach.mt.__name,
        ident = ident,
        iter = iter,
        body = body,
        pos = pos,
    }, Stat.ForEach.mt)
end
---@param key Atom.Ident
---@param value Atom.Ident
---@param iter Expr?
---@param body Body
---@return Stat.ForEachPair
function Stat.ForEachPair.new(key, value, iter, body, pos)
    ---@class Stat.ForEachPair
    return setmetatable({
        type = Stat.ForEachPair.mt.__name,
        key = key,
        value = value,
        iter = iter,
        body = body,
        pos = pos,
    }, Stat.ForEachPair.mt)
end
---@param expr Expr?
---@return Stat.Return
function Stat.Return.new(expr, pos)
    ---@class Stat.Return
    return setmetatable({
        type = Stat.Return.mt.__name,
        expr = expr,
        pos = pos,
    }, Stat.Return.mt)
end

---@alias Expr Expr.Atom|Expr.Binary|Expr.Unary|Expr.Call
local Expr = {
    Atom = {
        mt = {
            __name = "expr.atom"
        }
    },
    Binary = {
        mt = {
            __name = "expr.binary"
        }
    },
    Unary = {
        mt = {
            __name = "expr.unary"
        }
    },
    Call = {
        mt = {
            __name = "expr.call"
        }
    }
}
---@param atom Atom
---@return Expr.Atom
function Expr.Atom.new(atom, pos)
    ---@class Expr.Atom
    return setmetatable({
        type = Expr.Atom.mt.__name,
        atom = atom,
        pos = pos,
    }, Expr.Atom.mt)
end
---@param left Expr
---@param op BinaryOperator
---@param right Expr
---@return Expr.Binary
function Expr.Binary.new(left, op, right, pos)
    ---@class Expr.Binary
    return setmetatable({
        type = Expr.Binary.mt.__name,
        left = left,
        op = op,
        right = right,
        pos = pos,
    }, Expr.Binary.mt)
end
---@param op UnaryOperator
---@param right Expr
---@return Expr.Unary
function Expr.Unary.new(op, right, pos)
    ---@class Expr.Unary
    return setmetatable({
        type = Expr.Unary.mt.__name,
        op = op,
        right = right,
        pos = pos,
    }, Expr.Unary.mt)
end
---@param ident Atom.Ident
---@param args Expr[]
---@return Expr.Call
function Expr.Call.new(ident, args, pos)
    ---@class Expr.Call
    return setmetatable({
        type = Expr.Call.mt.__name,
        ident = ident,
        args = args,
        pos = pos,
    }, Expr.Call.mt)
end

---@alias Atom Atom.Ident|Atom.Number|Atom.String|Atom.Expr
local Atom = {
    Ident = {
        mt = {
            __name = "atom.ident"
        }
    },
    Number = {
        mt = {
            __name = "atom.number"
        }
    },
    String = {
        mt = {
            __name = "atom.string"
        }
    },
    Expr = {
        mt = {
            __name = "atom.expr"
        }
    },
}
---@param ident string
---@return Atom.Ident
function Atom.Ident.new(ident, pos)
    ---@class Atom.Ident
    return setmetatable({
        type = Atom.Ident.mt.__name,
        ident = ident,
        pos = pos,
    }, Atom.Ident.mt)
end
---@param number number
---@return Atom.Number
function Atom.Number.new(number, pos)
    ---@class Atom.Number
    return setmetatable({
        type = Atom.Number.mt.__name,
        number = number,
        pos = pos,
    }, Atom.Number.mt)
end
---@param string string
---@return Atom.String
function Atom.String.new(string, pos)
    ---@class Atom.String
    return setmetatable({
        type = Atom.String.mt.__name,
        string = string,
        pos = pos,
    }, Atom.String.mt)
end
---@param expr Expr
---@return Atom.Expr
function Atom.Expr.new(expr, pos)
    ---@class Atom.Expr
    return setmetatable({
        type = Atom.Expr.mt.__name,
        expr = expr,
        pos = pos,
    }, Atom.Expr.mt)
end

---@alias Node DataStat|Stat|Expr|Atom
return {
    DataStat = DataStat, Stat = Stat,
    Expr = Expr, Atom = Atom
}