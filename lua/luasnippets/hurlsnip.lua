local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

local function copy(args)
    return args[1]
end
return {
    -- When trying to expand a snippet, luasnip first searches the tables for
    -- each filetype specified in 'filetype' followed by 'all'.
    -- If ie. the filetype is 'lua.c'
    --     - luasnip.lua
    --     - luasnip.c
    --     - luasnip.all
    -- are searched in that order.
    hurl = {
        s("fn", {
            -- Simple static text.
            t("//Parameters: "),
            -- function, first parameter is the function, second the Placeholders
            -- whose text it gets as input.
            f(copy, 2),
            t({ "", "function " }),
            -- Placeholder/Insert.
            i(1),
            t("("),
            -- Placeholder with initial text.
            i(2, "int foo"),
            -- Linebreak
            t({ ") {", "\t" }),
            -- Last Placeholder, exit Point of the snippet. EVERY 'outer' SNIPPET NEEDS Placeholder 0.
            i(0),
            t({ "", "}" }),
        }),
    }
}
