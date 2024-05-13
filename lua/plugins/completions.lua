return {

        {
                'L3MON4D3/LuaSnip',
                keys = { { "<c-p>", mode = "i" } },
                config = function()
                        require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/lua/snippets" } })
                end,
        },
        {
                "hrsh7th/nvim-cmp",
                version = false, -- last release is way too old
                event = "InsertEnter",
                dependencies = {
                        'saadparwaiz1/cmp_luasnip',
                },
                config = function()
                        local cmp = require("cmp")
                        local ls = require("luasnip")
                        vim.keymap.set({ "i", "s" }, "<C-l>", function() ls.jump(1) end, { silent = true })
                        vim.keymap.set({ "i", "s" }, "<C-h>", function() ls.jump(-1) end, { silent = true })
                        cmp.setup({
                                mapping = {
                                        ['<CR>'] = cmp.mapping.confirm({
                                                behavior = cmp.ConfirmBehavior.Replace,
                                                select = true,
                                        }),
                                        ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
                                        ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' })
                                },
                                snippet = {
                                        expand = function(args)
                                                require('luasnip').lsp_expand(args.body)
                                        end,
                                },
                                sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'luasnip' } },
                                        { { name = 'buffer' }, }),
                                window = {
                                        completion = cmp.config.window.bordered(),
                                        documentation = cmp.config.window.bordered(),
                                },
                        });
                end
        }
}
