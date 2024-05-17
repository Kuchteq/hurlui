local inital_workspace_open = true

set_new_workspace = function(init_name, init_path)
        inital_workspace_open = false
        local workstation_setup_modal = require("modals.worksetup")
        workstation_setup_modal:show(init_name, init_path)
        api.nvim_feedkeys("i", "n", true) -- for whatever reason startinsert doesn't want to work
end

local set_new_workspace_keybinding = function()
        vim.keymap.set({ "i", "n" }, "<c-n>", function() api.nvim_win_close(0,true); set_new_workspace("", vim.fn.getcwd().."/.hurl") end, { buffer = api.nvim_get_current_buf() })
end

return {
        'natecraddock/workspaces.nvim',
        event = "VeryLazy",
        config = function()
                require("workspaces").setup(
                        {
                                hooks = {
                                        open = function()
                                                local picker = require("panels.picker")
                                                picker.dir_stack = {}
                                                if picker.win.id then
                                                        picker:fetch_items()
                                                        picker:draw()
                                                else
                                                        vim.keymap.set({ "n", "t" }, "<Tab>", function() require("tabs.controller"):shift() end);
                                                        picker:init()
                                                end
                                                vim.cmd.stopinsert()
                                        end,
                                }
                        }
                )

                -- This is de facto how the app starts, from this point you can
                -- trace what the user does and see what is being called
                require('telescope').load_extension("workspaces")
                if inital_workspace_open then
                        require("telescope").extensions.workspaces.workspaces()
                end
                set_new_workspace_keybinding()

                vim.keymap.set('n', '<leader>w', function()
                        require("telescope").extensions.workspaces.workspaces()
                        set_new_workspace_keybinding()
                end, {})
        end
}
