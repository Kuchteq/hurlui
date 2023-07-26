local Jwt = {
    win_id = nil,
    buf_id = nil,
    blueprint = {
        relative = "win",
        width = 40,
        height = 30,
        row = 0,
        col = 0,
        border = "rounded",
        style = "minimal",
        anchor = "NE"
    },
    get_decoded_value = function()
        local value = vim.fn.getreg('"')
        return vim.split(vim.fn.system("jwt decode '" .. value .. "'"), "\n")
    end,
    show = function(self)
        local output = self.get_decoded_value()
        self.blueprint.height = #output
        if not self.buf_id then
            self.buf_id = api.nvim_create_buf(true, true)
        end
        local max_width = math.max(unpack(vim.tbl_map(function(elem) return string.len(elem) end, output)))
        self.blueprint.width = max_width
            require('baleia').setup {}.buf_set_lines(self.buf_id, 0, -1, true, output)
        if not self.win_id then
            self.win_id = api.nvim_open_win(self.buf_id, false, self.blueprint)
             api.nvim_create_autocmd({ "WinLeave" }, {
                 callback = function()
                     --api.nvim_win_set_config(self.win_id, { relative = "cursor", row = 14, col = 49})
                     api.nvim_win_close(self.win_id, true)
                     self.win_id = nil
                 end,
                 once = true
             })
        else
            api.nvim_win_set_config(self.win_id, { relative = "win", row = 0, col = 0, height = #output })
        end
    end
}

vim.keymap.set("n", "<C-q>", ":bd<CR>", { silent = true })
vim.keymap.set("n", "<leader>t", function() Jwt:show() end)
