-- argparse.lua
-- Simple command line argument parser for CC:Tweaked (Lua 5.2)

local argparse = {}

-- Parses args table (from {...}) into options and positional arguments
-- opts: table of option definitions, e.g. {verbose = {short='v', has_value=false}}
function argparse.parse(args, opts)
    local options = {}
    local positionals = {}
    local i = 1
    while i <= #args do
        local arg = args[i]
        if arg:sub(1, 2) == "--" then
            local key, val = arg:match("^%-%-(%w[%w%-]*)=(.*)$")
            if key then
                options[key] = val
            else
                key = arg:sub(3)
                if opts and opts[key] and opts[key].has_value then
                    i = i + 1
                    options[key] = args[i]
                else
                    options[key] = true
                end
            end
        elseif arg:sub(1, 1) == "-" and #arg > 1 then
            local flags = arg:sub(2)
            for j = 1, #flags do
                local short = flags:sub(j, j)
                local found = false
                if opts then
                    for k, v in pairs(opts) do
                        if v.short == short then
                            found = true
                            if v.has_value then
                                i = i + 1
                                options[k] = args[i]
                            else
                                options[k] = true
                            end
                            break
                        end
                    end
                end
                if not found then
                    options[short] = true
                end
            end
        else
            table.insert(positionals, arg)
        end
        i = i + 1
    end
    return {options = options, positionals = positionals}
end

return argparse