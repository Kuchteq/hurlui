WorkspacesTelescopeWidget = {
    win_id = nil,
    buf_id = nil
}
return {
    {
        'natecraddock/workspaces.nvim',
        event = "VeryLazy",
        config = function()
            require("workspaces").setup(
                {
                    hooks = { open = function()
                        Picker:init()
                    end,
                    }
                }
            )

            require('telescope').load_extension("workspaces")
            require("telescope").extensions.workspaces.workspaces()

            WorkspacesTelescopeWidget.win_id = vim.api.nvim_get_current_win()
            WorkspacesTelescopeWidget.buf_id = vim.api.nvim_get_current_buf()

            vim.keymap.set({ "i", "n" }, "<c-s-n>", function()
                vim.api.nvim_win_close(0, true)
                require("workspaces").add(vim.fn.getcwd())
                Picker:init()
                --require("workspaces").open(get_file_name(vim.fn.getcwd()))
            end, { buffer = WorkspacesTelescopeWidget.buf_id })
        end
    }

}
