local turtlescript = require "turtlescript"
---@param err string
---@param epos Position?
local function print_error(err, epos)
    if epos then
        print(("ERROR: %s (ln %s, col %s)"):format(err, epos.ln.start, epos.col.start))
    else
        print(("ERROR: %s"):format(err))
    end
end
---@type string[]
local args = {...}
if args[1] then
    local path = args[1]
    local file = io.open(path, "r") if not file then print(("cannot open %q"):format(path)) return end
    ---@type string
    local text = file:read("*a") file:close()
    ---@diagnostic disable-next-line: param-type-mismatch
    local tokens, err, epos = turtlescript.lexer.lex(path, text) if err then print_error(err, epos) return end
    ---@diagnostic disable-next-line: param-type-mismatch
    local ast, err, epos = turtlescript.parser.parse(path, tokens) if err then print_error(err, epos) return end
    for _, stat in ipairs(ast) do
        print(stat)
        if stat.body then
            for _, stat in ipairs(stat.body) do
                print("", stat)
            end
        end
    end
else
    print "USAGE:"
    print "    ts [path] - runs the procedure 'main' in the program"
    print "    ts [path] [name] - runs the procedure name in the program"
end