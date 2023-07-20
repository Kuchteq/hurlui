vim.opt.fillchars = { eob = " " }
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.shortmess:append({ I = true })
vim.o.noshowcmd = 1
vim.o.noshowmode = 1
vim.o.laststatus = 1
vim.o.clipboard = "unnamedplus"
vim.keymap.set("n", "r", ":qa!<CR>");

--config = vim.tbl_deep_extend('force', config, opts)
vim.api.nvim_set_hl(0, "StatusLine", { bg = nil, fg = nil, sp = nil })
--vim.cmd("140 vsplit");
--

requestPickerWinId = vim.api.nvim_get_current_win();
vim.cmd.terminal("nnn");
vim.o.splitright = true;
vim.cmd("130 vsplit main")
requestEditorWinId = vim.api.nvim_get_current_win();
vim.cmd("60 vsplit output")
resultWinId = vim.api.nvim_get_current_win();

vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
        vim.api.nvim_set_current_win(requestPickerWinId)
    end
})
--vim.cmd("30 split")
--vim.api.nvim_set_current_win(primaryEditingSpaceWinId);
--requestPickerWinId=vim.api.nvim_get_current_win();

-- this line causes lazy nvim plugin manager to execute and load stuff from the plugins folder
runHurl = function()
    local toBeRun = vim.fn.expand('%');
    vim.api.nvim_set_current_win(resultWinId)
    vim.cmd("enew | read !hurl " .. toBeRun);
    vim.api.nvim_set_current_win(requestEditorWinId)
end

prepareForIncomingFile = function ()
    vim.api.nvim_set_current_win(requestEditorWinId)
end

vim.keymap.set("n","<F5>", runHurl);



--vim.o.splitright=true;
--vim.cmd("30 split asf")
