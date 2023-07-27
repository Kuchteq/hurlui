local u = require('utils')
local set_new_workspace_keybinding = function()
    vim.keymap.set({ "i", "n" }, "<c-n>", function()
        api.nvim_win_close(0, true)
        local workstation_setup_modal = require("modals.worksetup")
        workstation_setup_modal:show()
    end, { buffer = api.nvim_get_current_buf() })
end
return {
    {
        'natecraddock/workspaces.nvim',
        event = "VeryLazy",
        config = function()
            require("workspaces").setup(
                {
                    hooks = {
                        open = function()
                            local picker = require("panels.picker")
                            if picker.win.id then
                                picker:fetch_items()
                                picker:draw()
                            else
                                picker:init()
                            end
                        end,
                    }
                }
            )
            vim.keymap.set('n', '<leader>w', function ()
                require("telescope").extensions.workspaces.workspaces()
                set_new_workspace_keybinding()
            end, {})
            require('telescope').load_extension("workspaces")
            require("telescope").extensions.workspaces.workspaces()
            set_new_workspace_keybinding()
        end
    },
}
