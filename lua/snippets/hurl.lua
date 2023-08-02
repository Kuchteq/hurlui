local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

return {
        s("rg", {
            t("GET https://{{host}}/"),
        }),
        s("rp", {
            t("POST https://{{host}}/"),
        }),
        s("rP", {
            t("PUT https://{{host}}/"),
        }),
        s("rd", {
            t("DELETE https://{{host}}/"),
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
