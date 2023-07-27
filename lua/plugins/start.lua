-- This is acts as the entry to the program
local u = require('utils')
return {
    {
        'natecraddock/workspaces.nvim',
        event = "VeryLazy",
        config = function()
            require("workspaces").setup(
                {
                    hooks = { open = function()
                        require("panels.picker"):init()
                    end,
                    }
                }
            )
            require('telescope').load_extension("workspaces")
            require("telescope").extensions.workspaces.workspaces()

            vim.keymap.set({ "i", "n" }, "<c-s-n>", function()
                api.nvim_win_close(0, true)
                require("workspaces").add(vim.fn.getcwd())
                require("panels.picker"):init()
                require("workspaces").open(u.get_file_name(vim.fn.getcwd()))
                --
            end, { buffer = api.nvim_get_current_buf() })
        end
    },
}
