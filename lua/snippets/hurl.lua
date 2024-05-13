local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

return {
        s("rg", {
            t("GET {{proto}}{{host}}/"),
        }),
        s("rp", {
            t("POST {{proto}}{{host}}/"),
        }),
        s("rP", {
            t("PUT {{proto}}{{host}}/"),
        }),
        s("rd", {
            t("DELETE {{proto}}{{host}}/"),
        }),
        s("au", {
            t("Authorization: Bearer "),
            i(1, "{{token}}")
        }),
        s("ab", {
            t({"[BasicAuth]",""}),
            i(1, "username"), t(":"), i(2, "password")
        }),
        s("ia", {t{"#include auth",""}}),
        s("jr", {
            t({"{",""}),
            t({ '       "username": "' }),i(1, "user"),
            t({ '",','       "password": "' }),i(2, "pass"),
            t({ '"',"}" })
        }),
        s("el", {
            t({"proto=http"},{host="localhost:"})
        }),
        s("qs", {
            t("[QueryStringParams]"),
        }),
}
