return {
    -- {
    --     "Kuchteq/vimoblush",
    --     lazy = false, -- make sure we load this during startup if it is your main colorscheme
    --     priority = 1000, -- make sure to load this before all the other start plugins
    --     config = function()
    --         -- TODO BUG the colormode switching does not work if we have used toggleterm in our session before
    --         if vim.fn.filereadable("/tmp/theme") == 1 then
    --             SYSTHEME = vim.fn.readfile("/tmp/theme")[1]
    --             vim.opt.background = SYSTHEME == "dark" and "dark" or "light"
    --             if SYSTHEME == "light" then
    --                 require('everblush').setup({ lightmode = SYSTHEME, false })
    --             end
    --         end
    --         vim.cmd([[colorscheme everblush]])
    --
    --         -- function for ~/.local/bin/themeset
    --         function themeset(theme)
    --             SYSTHEME = theme
    --             local booledSystheme = SYSTHEME == "light" and true or false;
    --             vim.opt.background = booledSystheme and "light" or "dark"
    --             require('everblush').setup({ lightmode = booledSystheme, transparent_background = not booledSystheme })
    --             vim.cmd([[colorscheme everblush]])
    --             os.execute("colormodeset " .. SYSTHEME)
    --         end
    --     end,
--    },

    {
        'natecraddock/workspaces.nvim',
        event =  "VeryLazy" ,
        config = function()
            require("workspaces").setup(
                {
                    hooks = { open = "Telescope find_files",
                    }
                }
            )
            require('telescope').load_extension("workspaces")
--            require("telescope").extensions.workspaces.workspaces()
        end
    }

}
