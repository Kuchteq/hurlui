P = function(a) -- debugging print
    print(vim.inspect(a))
end
-- CODE RELATED TO SEPERATING HURLUI FROM REGULAR NVIM
local old_stdpath = vim.fn.stdpath
---@diagnostic disable-next-line: duplicate-set-field
vim.fn.stdpath = function(value)
    if value == "data" then
        return vim.env.XDG_DATA_HOME .. "/hurlui"
    end
    if value == "cache" then
        return vim.env.XDG_CACHE_HOME .. "/hurlui"
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
require('utils')
require("theme")
require("request_explorer")

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


local blankBufId = vim.api.nvim_create_buf(true, true);
local initial_cursor_shape = vim.o.guicursor;

-- Though creating three variables that are very similar may seem like a redundancy for now
-- But this is just leaving the room for future improvements and side effect callbacks
local Editor = {
    win_id = nil,
    win_close = function(self)
        vim.api.nvim_win_close(self, true)
    end,
    current_req_name = nil;
    win_set_width = function(self, width)
        vim.api.nvim_win_set_width(self.win_id, math.floor(width))
    end,
    receiveEditor = function(self, requestFilePath)
        Tabs.runner:enter()
        self:win_set_focus();
        vim.cmd.edit(requestFilePath);
        self.current_req_name = trunc_extension(vim.fn.expand('%:~:.'))
        vim.api.nvim_win_set_option(self.win_id, "statusline", "%= Editor — " .. self.current_req_name  .. "%=")
    end,
    get_current_file_buf_id = function(self)
        return vim.api.nvim_win_get_buf(self.win_id)
    end,
    get_current_file_path = function(self)
        return get_buf_name_by_win_in(self.win_id);
    end,
    win_set_focus = function(self)
        vim.api.nvim_set_current_win(self.win_id)
    end
}


local Output = {
    win_id = nil,
    win_set_focus = function(self)
        vim.api.nvim_set_current_win(self.win_id)
    end,
    win_close = function(self)
        vim.api.nvim_win_close(self, true)
    end,
    win_set_width = function(self, width)
        vim.api.nvim_win_set_width(self.win_id, math.floor(width))
    end,
    set_buffer = function(self, bufferId)
        vim.api.nvim_win_set_buf(self.win_id, bufferId);
    end,
    receiveOutput = function(self, outputPath, statusResponse)
        Tabs.runner:enter()
        if outputPath ~= "" then
            vim.cmd.badd(outputPath) -- fetch the given file and create a buffer for it
            local outputBufferId = vim.api.nvim_list_bufs()[#vim.api.nvim_list_bufs()]
            vim.api.nvim_win_set_buf(self.win_id, outputBufferId);
        else
            vim.api.nvim_win_set_buf(self.win_id, blankBufId); -- if there is no response, i.e. most probably an error, set the blank buffer
        end
        if statusResponse ~= nil then
            if string.find(statusResponse, "error") then
                Tabs.runner.status:update("%#HttpErrorFill#" .. statusResponse)
            else
                Tabs.runner.status:update("%#HttpSuccessFill#" .. statusResponse)
            end
        else
            Tabs.runner.status:update("")
        end
        vim.api.nvim_win_set_option(self.win_id, "statusline", "%= ".. Editor.current_req_name .." at %t %=")
    end
}


local EnvEditorFactory = {
    win_id = nil,
    win_close = function(self)
        vim.api.nvim_win_close(self, true)
    end,
    win_set_width = function(self, width)
        vim.api.nvim_win_set_width(self.win_id, math.floor(width))
    end,
    init = function(self)
        local instance = {}
        setmetatable(instance, { __index = self })
        instance.win_id = vim.api.nvim_get_current_win();
        return instance
    end,
    get_current_file_path = function(self)
        return get_buf_name_by_win_in(self.win_id);
    end,
    win_set_focus = function(self)
        vim.api.nvim_set_current_win(self.win_id)
    end
}

Tabs = {
    runner = {
        inited = false,
        isSmaller = false,
        updateWinSize = function(self)
            if self.inited then
                local wholeTerminalWidth = vim.go.columns;
                if wholeTerminalWidth >= 80 then -- Choose the larger variant
                    if self.isSmaller == true then
                        self.fromSmallerLayout()
                        self.isSmaller = false
                    end
                    Picker:win_set_width(wholeTerminalWidth * 0.22)
                    Output:win_set_width(wholeTerminalWidth * 0.30)
                else
                    if wholeTerminalWidth < 80 then -- Choose the smaller variant
                        if self.isSmaller == false then
                            self.toSmallerLayout();
                            self.isSmaller = true;
                        end
                        Picker:win_set_width(wholeTerminalWidth * 0.22)
                        Editor:win_set_width(wholeTerminalWidth * 0.78)
                    end
                end
            end
        end,
        toSmallerLayout = function()
            Picker:win_close()
            Editor:win_set_focus()
            vim.cmd("belowright split output")
            Picker.win_id = vim.api.nvim_get_current_win() -- keep win_id up to date
            Editor:win_set_focus()
        end,
        fromSmallerLayout = function()
            Picker:win_close()
            Editor:win_set_focus()
            vim.cmd("vsplit output")
            Picker.win_id = vim.api.nvim_get_current_win();
            Editor:win_set_focus();
        end,
        run_hurl = function()
            vim.api.nvim_command('silent! update')
            local hurl_file_path = Editor:get_current_file_path()
            local appended_env_path = Tabs.env.selected and "'" .. Tabs.env.selected .. "'" or "";
            vim.fn.system("executer '" .. hurl_file_path .. "' " .. appended_env_path)
        end,
        enter = function(self)
            if not self.inited then
                vim.o.splitright = true;
                vim.cmd.vsplit()
                Editor.win_id = vim.api.nvim_get_current_win();
                vim.cmd.vsplit()
                Output.win_id = vim.api.nvim_get_current_win();
                Output:set_buffer(blankBufId)
                vim.api.nvim_buf_set_name(blankBufId, "output");

                -- KEYBINDINGS
                vim.keymap.set({ "n", "t" }, "<C-h>", "<C-w>h")
                vim.keymap.set({ "n", "t" }, "<C-j>", "<C-w>j")
                vim.keymap.set({ "n", "t" }, "<C-k>", "<C-w>k")
                vim.keymap.set({ "n", "t" }, "<C-l>", "<C-w>l")

                vim.keymap.set("n", "<F1>", function() Picker:win_set_focus() end)
                vim.keymap.set({ "t", "n" }, "<F2>", function() Editor:win_set_focus() end)
                vim.keymap.set({ "t", "n" }, "<F3>", function() Output:win_set_focus() end)
                vim.keymap.set("n", "<S-enter>", function()
                    if TabsController.current_tab == 2 then
                        Tabs.env.alternator = vim.api.nvim_buf_get_name(0);
                        --vim.api. = "grzyb %f %=" -- Center the bottom status line
                    end
                end);
                vim.keymap.set("n", "<leader>a", function()
                    Tabs.env:alternate();
                end);

                vim.keymap.set("n", "<enter>", function()
                    if TabsController.current_tab == 1 then
                        self:run_hurl();
                    else
                        Tabs.env:select(vim.api.nvim_buf_get_name(0));
                        Tabs.env:buf_labels_refresh();
                    end
                end, {silent=true});
                vim.keymap.set({ "n", "t" }, "<Tab>", function() TabsController:shift() end);
                -- unfortunately these need to be wrapped with anonymous(anoyingmous)
                -- functions because we are accessing self inside the function
                self.inited = true
                self:updateWinSize()
            end
        end,
        status = {
            text = "",
            update = function(self, incoming)
                self.text = incoming;
            end
        }
    },
    env = {
        inited = false,
        paths = nil, -- nil means env has not yet been initialized,
        -- false directory is non existant and {} that there are no files in directory
        env_editors = {},
        alternator = nil,
        alternate = function(self)
            -- If we don't have an alternator, we grab the first thing that isn't selected
            if self.paths and #self.paths > 1 then
                if not self.alternator then
                    self.alternator = first_not_present(self.paths, self.selected);
                end
                local tmp = self.selected;
                self:select(self.alternator);
                self.alternator = tmp;
            end
        end,
        get_tabline_name = function(self)
            if self.paths == nil then
                return "Envs"
            elseif self.paths == false then
                return "(No) Envs"
            end
            return #self.paths .. " Envs"
        end,
        selected = nil,
        select = function(self, path)
            self.selected = path;
            TabsController:redraw_line()
        end,
        set_default_selected = function(self)
            self.selected = self.paths and contains_substring_in_table(self.paths, DEFAULT_ENVSPACE_NAME) or nil
        end,
        rescan = function(self)
            if vim.loop.fs_scandir(".envs") then
                local result = vim.fn.glob(".envs/*")
                self.paths = result ~= "" and vim.split(result, '\n') or {}
            else
                self.paths = false
            end
        end,
        enter = function(self)
            self:rescan()
            if not Tabs.env.inited and self.paths and #self.paths > 0 then
                for i = 1, #self.paths do
                    if i == 1 then vim.cmd.tabnew(self.paths[1]) else vim.cmd.vsplit(self.paths[i]) end
                    local newWindow = EnvEditorFactory:init()
                    vim.bo.filetype = "sh"
                    table.insert(self.env_editors, newWindow);
                    vim.api.nvim_win_set_hl_ns(newWindow.win_id, ENV_EDITOR_NS);
                end
                vim.api.nvim_set_current_win(self.env_editors[1].win_id)
                self.inited = true
            elseif not self.paths or #self.paths <= 0 then
                Tabs.runner.status:update("%#Normal#No envs! Make sure you have the 'envs' directory and at least one file there")
            end
            self:buf_labels_refresh()
        end,
        buf_labels_refresh = function(self)
            for i = 1, #self.env_editors do
                local editor = self.env_editors[i]
                local title = "%= %t %=";
                if get_file_name(editor:get_current_file_path()) == get_file_name(self.selected) then
                    title = "%= selected: %t %=";
                elseif self.alternator and get_file_name(editor:get_current_file_path()) == get_file_name(self.alternator) then
                    title = "%= alternative: %t %=";
                end
                vim.api.nvim_win_set_option(editor.win_id, "statusline", title)
            end
        end,
        status = {
            text = "",
            onEnterUpdate = function(self)
                if self.paths and #self.paths > 0 then
                    self.text = "No env files in workspace's directory"
                elseif self.paths then
                    self.text = "No envs directory in workspace"
                else
                    self.text = #self.paths .. " enviornments"
                end
            end
        }
    }
}

TabsController = {
    current_tab = 1,
    _boiler_line_prepare = function(self, num)
        return '%' .. num .. 'T' .. (num == self.current_tab and '%#TabLineSel# ' or '%#TabLine# ')
    end,
    get_line = function(self)
        -- Runner always has the tabId of 1 and env page 2
        self.current_tab = vim.fn.tabpagenr()
        -- tab_info is essentially what is displayed on the left
        local tab_info = self:_boiler_line_prepare(1) .. "Runner ";
        tab_info = tab_info .. self:_boiler_line_prepare(2) .. Tabs.env:get_tabline_name() .. " %#TabLineFill#%=";     -- %= gives the alignment to right
        local env_info = Tabs.env.selected and "%#EnvBarFill# env: " .. get_file_name(Tabs.env.selected) .. " " or ''; -- Env info expects path
        return tab_info .. (self.current_tab == 1 and Tabs.runner.status.text or Tabs.env.status.text) .. env_info;
    end,
    shift = function(self)
        vim.cmd.tabNext()
        Tabs.env:enter()
        self.current_tab = vim.fn.tabpagenr();
        self:redraw_line()
    end,
    redraw_line = function()
        vim.cmd.redrawtabline()
    end
}

-- AUTOCMDS
-- Makes sure that the user is able to choose the request straight away
vim.api.nvim_create_autocmd({ "WinEnter" }, {
    callback = function()
        Picker.hide_cursor()
    end
})
-- autosave
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertLeave" }, {
  callback = function()
      vim.api.nvim_command('silent update')
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave" }, {
    callback = function()
        if Picker.win_id == vim.api.nvim_get_current_win() then
            vim.o.guicursor = initial_cursor_shape;
        end
    end
})
-- Make the window responsive
vim.api.nvim_create_autocmd({ "VimResized" }, {
    callback = function()
        if Tabs.runner.inited then
            Tabs.runner:updateWinSize()
        end
    end
})

-- HOOKS for remote hurl callbacks from executer script
RECEIVE_EDITOR = function(filePath)
    Editor:receiveEditor(filePath)
end
RECEIVE_OUTPUT = function(filePath, statusResponse)
    Output:receiveOutput(filePath, statusResponse)
end
TABLINE_UPDATE = function()
    return TabsController:get_line()
end

Picker:init()
Tabs.env:rescan()
Tabs.env:set_default_selected()


vim.go.tabline = "%!v:lua.TABLINE_UPDATE()"
require("lazy").setup("plugins")
