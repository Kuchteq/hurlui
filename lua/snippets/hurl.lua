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
        s("rg", {
            -- Simple static text.
            t("GET http://{{host}}/"),
        }),
        s("rp", {
            -- Simple static text.
            t("POST http://{{host}}/"),
        }),
        s("rP", {
            -- Simple static text.
            t("PUT http://{{host}}/"),
        }),
        s("rd", {
            -- Simple static text.
            t("DELETE http://{{host}}/"),
        }),
        s("au", {
            -- Simple static text.
            t("Authorization: "),
        }),
        s("qs", {
            -- Simple static text.
            t("[QueryStringParams]"),
        }),



}
