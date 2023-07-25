return {
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
            require("telescope").extensions.workspaces.workspaces()

            local workspace_picker_buf_id = vim.api.nvim_get_current_buf()
            vim.keymap.set({"i","n"}, "<c-s-n>", function ()
                    require("workspaces").add_dir(vim.fn.getcwd())
            end, {buffer=workspace_picker_buf_id})
        end
    }

}
