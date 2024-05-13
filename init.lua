---@diagnostic disable-next-line: lowercase-global
api = vim.api

-- Easier debugging
P = function(a)
    print(vim.inspect(a))
end
vim.keymap.set({ "n", "t" }, "<c-s-q>", ":qa!<CR>")

-- CODE RELATED TO SEPERATING HURLUI FROM REGULAR NVIM
local old_stdpath = vim.fn.stdpath
---@diagnostic disable-next-line: duplicate-set-field
vim.fn.stdpath = function(value)
    if value == "data" then
        return vim.env.HURLUI_NV_DATA
    end
    if value == "cache" then
        return vim.env.HURLUI_NV_CACHE
    end
    if value == "config" then
        return vim.env.HURLUI_HOME
    end
    return old_stdpath(value)
end
vim.opt.runtimepath:remove(vim.fn.expand('~/.config/nvim'))
vim.opt.packpath:remove(vim.fn.expand('~/.local/share/nvim/site'))
vim.opt.runtimepath:append(vim.fn.stdpath('config'))
vim.opt.packpath:append(vim.fn.stdpath('data') .. '/packages')

-- Globals
DEFAULT_ENVSPACE_NAME = vim.env.DEFAULT_ENVSPACE_NAME
OUTPUT_BASE = vim.env.OUTPUT_BASE
INITIAL_CURSOR_SHAPE = vim.o.guicursor;

-- SET UP LAZY PACKAGE MANAGER
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, }) end
vim.opt.rtp:prepend(lazypath)

--MISC SETTINGS
vim.g.mapleader = ' '
vim.o.title = true
vim.o.cursorline = true
vim.o.titlestring = 'Hurlui'
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.showtabline = 2
vim.opt.fillchars = { eob = " " }
vim.opt.shortmess:append({ I = true })
vim.opt.showmode = false
vim.opt.swapfile = false
vim.o.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.termguicolors = true
vim.o.laststatus = 2
vim.opt.statusline = "%= %t %="                    -- Center the bottom status line
vim.opt.undodir = { vim.fn.stdpath('cache') .. "/hurly/.undodir" } -- set up undodir
vim.opt.undofile = true
vim.o.splitright = true;
vim.api.nvim_tabpage_set_var(0, "purpose", "runner")
vim.cmd.tabnew()
vim.api.nvim_tabpage_set_var(0, "purpose", "env")
vim.cmd.tabprevious()

require("theme")
require("modals.jwt")
require("lazy").setup("plugins")


-- keybindings
vim.keymap.set({ "n", "t" }, "<C-h>", "<C-w>h")
vim.keymap.set({ "n", "t" }, "<C-j>", "<C-w>j")
vim.keymap.set({ "n", "t" }, "<C-k>", "<C-w>k")
vim.keymap.set({ "n", "t" }, "<C-l>", "<C-w>l")
vim.keymap.set("n", "<c-n>", function() require("modals.request"):show() end)
vim.keymap.set("n", "<c-s-d>", function() require("modals.dir"):show() end)
vim.keymap.set({ "i", "n" }, "<c-s-e>", function() if require("panels.picker").win.id then require("modals.envsetup").show() end end)
vim.keymap.set("n", "<leader>a", function() require("tabs.env"):alternate(); end);
vim.keymap.set("n", "<S-enter>", function()
    local env_tab = require("tabs.env")
    if api.nvim_get_current_tabpage() ==  env_tab.get_tabpage() then
        env_tab:alternator_select(api.nvim_buf_get_name(0));
    end
end);

vim.keymap.set("n", "<enter>", function()
    local runner_tab = require("tabs.runner")
    local env_tab = require("tabs.env")
    if api.nvim_get_current_tabpage() == runner_tab.get_tabpage() then
        runner_tab:run_hurl();
    else
        env_tab:select(api.nvim_buf_get_name(0));
        env_tab:buf_labels_refresh();
    end
end, { silent = true });


-- Though creating three variables that are very similar may seem like a redundancy for now
-- But this is just leaving the room for future improvements and side effect callbacks


-- AUTOCMDS
-- autosave
api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertLeave" }, {
    callback = function()
        if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
            api.nvim_command('silent update')
        end
    end,
})

-- This allows the terminal to keep up with the workspaces path
local sync_dir_with_shell = function()
    vim.api.nvim_chan_send(2, '\x1b]7;file://' .. vim.fn.hostname() .. vim.fn.getcwd())
end
vim.api.nvim_create_autocmd({ "DirChanged" }, {
    callback = sync_dir_with_shell
})

-- Make the window responsive
api.nvim_create_autocmd({ "VimResized" }, {
    callback = function()
        local tabs_runner = require("tabs.runner")
        if tabs_runner.inited then
            tabs_runner:update_win_size()
        end
    end
})
require("modals.envsetup")

TABLINE_UPDATE = function()
    return require("tabs.controller"):get_line()
end

vim.go.tabline = "%!v:lua.TABLINE_UPDATE()"
