return {
    {
        'natecraddock/workspaces.nvim',
        event =  "VeryLazy" ,
        config = function()
            require("workspaces").setup(
                {
                    hooks = { open = function ()
                        Picker:init()
                    end,
                    }
                }
            )

            require('telescope').load_extension("workspaces")
            require("telescope").extensions.workspaces.workspaces()

            local workspace_picker_buf_id = vim.api.nvim_get_current_buf()
            vim.keymap.set({"i","n"}, "<c-s-n>", function ()
                    vim.api.nvim_win_close(0, true)
                    require("workspaces").add(vim.fn.getcwd())
                    require("workspaces").open(get_file_name(vim.fn.getcwd()))
            end, {buffer=workspace_picker_buf_id})
        end
    }

}
