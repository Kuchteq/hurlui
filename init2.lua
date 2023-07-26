---@diagnostic disable-next-line: lowercase-global
api = vim.api

-- Easier debugging
P = function(a)
    print(vim.inspect(a))
end
vim.keymap.set("n", "r", ":qa!<CR>");

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
vim.o.noshowcmd = 1
vim.opt.showtabline = 2
vim.opt.fillchars = { eob = " " }
vim.opt.shortmess:append({ I = true })
vim.opt.showmode = false
vim.opt.swapfile = false
vim.o.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.termguicolors = true
vim.o.laststatus = 2
vim.opt.statusline = "%= %{expand('%:~:.')} %="                    -- Center the bottom status line
vim.opt.undodir = { vim.fn.stdpath('cache') .. "/hurly/.undodir" } -- set up undodir
vim.opt.undofile = true

