local old_stdpath = vim.fn.stdpath
OUTPUT_BASE = os.getenv("OUTPUTBASE");
vim.fn.stdpath = function(value)
    if value == "data" then
        return os.getenv("XDG_DATA_HOME") .. "/hurlord"
    end
    if value == "cache" then
        return os.getenv("XDG_CACHE_HOME") .. "/hurlord"
    end
    if value == "config" then
        return os.getenv("XDG_CONFIG_HOME") .. "/hurlord"
    end
    return old_stdpath(value)
end
vim.opt.runtimepath:remove(vim.fn.expand('~/.config/nvim'))
vim.opt.packpath:remove(vim.fn.expand('~/.local/share/nvim/site'))
vim.opt.runtimepath:append(vim.fn.expand('~/.config/hurlord'))
vim.opt.packpath:append(vim.fn.expand('~/.local/share/hurlord/packages'))

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }) end
vim.opt.rtp:prepend(lazypath)
P = function(a)
    print(vim.inspect(a))
end

require("lazy").setup("plugins")
vim.opt.fillchars = { eob = " " }
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.shortmess:append({ I = true })
vim.o.noshowcmd = 1
vim.o.laststatus = 1
vim.opt.showmode = false
vim.opt.swapfile = false
vim.o.clipboard = "unnamedplus"
vim.keymap.set("n", "r", ":qa!<CR>");

--config = vim.tbl_deep_extend('force', config, opts)
vim.opt.termguicolors = true
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "#005577", fg = "#ffffff", sp = nil })
vim.api.nvim_set_hl(0, "StatusLine", { bg = "#B400B4", fg = nil, sp = nil })
--vim.cmd("140 vsplit");
--

pickerWinId = vim.api.nvim_get_current_win();
vim.cmd.terminal({ "nnn" });
vim.cmd.file("picker");
vim.o.splitright = true;
vim.cmd("vsplit main")
editorWinId = vim.api.nvim_get_current_win();
vim.cmd("vsplit output")
outputWinId = vim.api.nvim_get_current_win();
vim.opt.statusline = "%= %f %="
vim.o.filetype = true;


vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
        vim.cmd.startinsert();
        vim.api.nvim_set_current_win(pickerWinId)
    end
})


vim.api.nvim_create_autocmd({ "InsertLeave" }, { command = "silent write" })

vim.api.nvim_create_autocmd({ "VimResized" }, {
    callback = function()
        resizeAll()
    end
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
    callback = function()
    end
})
isSmaller = false
resizeAll = function()
    local wholeTerminalWidth = vim.go.columns

    if wholeTerminalWidth < 80 then
        if isSmaller == false then
            toSmallerLayout();
            isSmaller = true;
        end
        vim.api.nvim_win_set_width(pickerWinId, math.floor(wholeTerminalWidth * 0.22))
        vim.api.nvim_win_set_width(editorWinId, math.floor(wholeTerminalWidth * 0.78))
    elseif wholeTerminalWidth >= 80 then
        if isSmaller == true then
            fromSmallerLayout()
            isSmaller = false
        end
        vim.api.nvim_win_set_width(pickerWinId, math.floor(wholeTerminalWidth * 0.12))
        vim.api.nvim_win_set_width(outputWinId, math.floor(wholeTerminalWidth * 0.40))
    end

    -- Leaving the biggest portion for the editor
end
resizeAll()
--vim.cmd("30 split")
--vim.api.nvim_set_current_win(primaryEditingSpaceWinId);
--requestPickerWinId=vim.api.nvim_get_current_win();
function getFileNameWithoutExtension(path)
    -- Find the position of the last slash or backslash in the path
    local lastSlashPos = path:find("[/\\][^/\\]*$")

    -- If a slash or backslash is found, extract the file name
    local fileName = lastSlashPos and path:sub(lastSlashPos + 1) or path

    -- Find the position of the last dot in the file name (before the extension)
    local lastDotPos = fileName:find("%.[^%.]*$")

    -- If a dot is found, remove the extension from the file name
    return lastDotPos and fileName:sub(1, lastDotPos - 1) or fileName
end

runHurl = function()
    vim.cmd("silent write")
    toBeRunBufNumber = vim.api.nvim_win_get_buf(editorWinId)
    toBeRunPath = vim.api.nvim_buf_get_name(toBeRunBufNumber)

    outputPath = vim.fn.system("executer " .. toBeRunPath);
    vim.cmd.badd(outputPath)
    local outputBufferId = vim.api.nvim_list_bufs()[#vim.api.nvim_list_bufs()]
    vim.api.nvim_win_set_buf(outputWinId, outputBufferId);
end


prepareEditor = function()
    vim.api.nvim_set_current_win(editorWinId)
end

prepareOutput = function()
    vim.api.nvim_set_current_win(outputWinId)
end
focusOnEditor = function()
    vim.api.nvim_set_current_win(editorWinId)
end

focusOnPicker = function()
    vim.cmd.startinsert();
    vim.api.nvim_set_current_win(pickerWinId)
end

focusOnOutput = function()
    vim.api.nvim_set_current_win(outputWinId)
end

toSmallerLayout = function()
    focusOnPicker()
    vim.api.nvim_win_close(outputWinId, true)
    focusOnEditor()
    vim.cmd("belowright split output")
    outputWinId = vim.api.nvim_get_current_win();
    focusOnEditor()
end

fromSmallerLayout = function()
    focusOnOutput()
    vim.api.nvim_win_close(outputWinId, true)
    focusOnEditor()
    vim.cmd("vsplit output")
    outputWinId = vim.api.nvim_get_current_win();
    focusOnEditor()
end

vim.keymap.set("n", "<enter>", runHurl);
vim.keymap.set("n", "<F1>", focusOnPicker);
vim.keymap.set({ "t", "n" }, "<F2>", focusOnEditor);
vim.keymap.set({ "t", "n" }, "<F3>", focusOnOutput);
