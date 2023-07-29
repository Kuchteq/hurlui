local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

return {
        s("rg", {
            t("GET http://{{host}}/"),
        }),
        s("rp", {
            t("POST http://{{host}}/"),
        }),
        s("rP", {
            t("PUT http://{{host}}/"),
        }),
        s("rd", {
            t("DELETE http://{{host}}/"),
        }),
        s("au", {
            t("Authorization: "),
        }),
        s("ab", {
            t("[BasicAuth]"),
            t({ "", "" }),
        }),
        s("qs", {
            t("[QueryStringParams]"),
        }),
}
