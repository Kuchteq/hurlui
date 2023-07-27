return {
    {
        "https://github.com/m00qek/baleia.nvim",
        lazy = true,
    },
    "phaazon/hop.nvim",
    branch = 'v2',
    config = function()
        require("hop").setup()
        vim.keymap.set({ 'o', 'n' }, '<c-w>', function()
            require("hop").hint_words({ current_line_only = true })
        end, { remap = true })

        vim.keymap.set({ 'o', 'n' }, '<c-a>', function()
            require("hop").hint_words({ current_line_only = true, hint_position = require 'hop.hint'.HintPosition.END })
        end, { remap = true })
    end
}
