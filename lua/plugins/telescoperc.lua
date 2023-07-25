return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = { 'æ', 'ŋ', '’' },
    config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', 'æ', builtin.find_files, {})

        vim.keymap.set('n', '<leader>h', function()
            builtin.find_files({ cwd = "/tmp/hurlord", find_command = { "rg", "--files", "--sort", "modified", "." }, bufnr = 3 })
        end, {})
        vim.keymap.set('n', 'ŋ', builtin.live_grep, {})
        vim.keymap.set('n', '’', builtin.resume, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})
        require('telescope').setup {
            defaults = {
                mappings = {
                    i = {
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                        ["<C-p>"] = "cycle_history_prev",
                        -- ['<Enter>'] = function(prompt_bufnr)
                        --     -- Use nvim-window-picker to choose the window by dynamically attaching a function
                        --     local action_set = require('telescope.actions.set')
                        --     local action_state = require('telescope.actions.state')
                        --
                        --     local picker = action_state.get_current_picker(prompt_bufnr)
                        --     picker.get_selection_window = function(picker, entry)
                        --         picker.get_selection_window = nil
                        --         return Picker.win_id
                        --     end
                        --     vim.api.nvim_win_set_option(Picker.win_id, "statusline", "%#Comment#%{'Old'}%* " .. getWindowBufName(Picker.win_id))
                        --     return action_set.edit(prompt_bufnr, 'edit')
                        -- end,
                        ["<C-n>"] = "cycle_history_next",
                        ["ŋ"] = "close",
                        ["æ"] = "close"
                    }
                }
            } }
    end
}
