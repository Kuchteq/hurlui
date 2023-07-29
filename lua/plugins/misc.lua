return {
    {
        "https://github.com/m00qek/baleia.nvim",
        lazy = true,
    },
    {
        'stevearc/dressing.nvim',
        opts = {},
        config = function()
            require('dressing').setup({
                input = {
                    relative = "editor"
                }
            })
        end
    },
    {
        "phaazon/hop.nvim",
        config = function()
            require("hop").setup()
            vim.keymap.set({ 'o', 'n' }, '<c-w>', function() require("hop").hint_words({ current_line_only = true }) end, { remap = true })

            vim.keymap.set({ 'o', 'n' }, '<c-a>', function()
                require("hop").hint_words({ current_line_only = true, hint_position = require 'hop.hint'.HintPosition.END })
            end, { remap = true })
        end
    }
}
