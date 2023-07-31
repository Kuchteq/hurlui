local u = require('utils')
local tabs_controller = require("tabs.controller")
local get_env_editor = require('panels.get_env_editor')


return {
    inited = true,
    paths = {}, -- nil means env has not yet been initialized,
    -- false directory is non existant and {} that there are no files in directory
    env_editors = {},
    alternator = nil,
    alternator_select = function(self, path)
        self.alternator = path;
        self:buf_labels_refresh()
    end,
    alternate = function(self)
        -- If we don't have an alternator, we grab the first thing that isn't selected
        if self.paths and #self.paths > 1 then
            if not self.alternator then
                self.alternator = u.first_not_present(self.paths, self.selected);
            end
            local tmp = self.selected;
            self:select(self.alternator);
            self.alternator = tmp;
            self:buf_labels_refresh()
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
        if path == self.alternator then
            self.alternator = nil;
        end
        tabs_controller:redraw_line()
        self:buf_labels_refresh()
    end,
    set_defaults = function(self)
        if self.paths then
            self.selected = u.tbl_first_string_with_substring(self.paths, DEFAULT_ENVSPACE_NAME);
            self.alternator = #self.paths > 1 and u.first_not_present(self.paths, self.selected) or nil;
        end
    end,
    rescan = function(self)
        if vim.loop.fs_scandir(".envs") then
            local result = vim.fn.glob(vim.fn.getcwd() .. "/.envs/*")
            self.paths = result ~= "" and vim.split(result, '\n') or {}
        else
            self.paths = false
        end
    end,
    enter = function(self, focus_on_name)
        -- Try out a new approach of relying solely on what neovim is doing
        self:rescan()
        api.nvim_set_current_tabpage(2)
        -- Since self.path saves using the full path name, we are checking if there is something that is not already present using the name
        local visible_window_paths = u.tabpage_get_bufs_names(2)
        local to_be_shown_window_paths = vim.tbl_filter(function(val)
            return not vim.tbl_contains(visible_window_paths, val);
        end, self.paths)
        for _, path in ipairs(to_be_shown_window_paths) do
            if api.nvim_buf_get_name(0) == "" then
                vim.cmd.edit(path)
            else
                vim.cmd.vsplit(path)
            end
            vim.bo.filetype = "sh"
            api.nvim_win_set_hl_ns(api.nvim_get_current_win(), ENV_EDITOR_NS);
        end
        if focus_on_name then
            u.set_win_focus_by_buf_name(focus_on_name)
        end
        self:buf_labels_refresh()
    end,
    add = function(self, name)
        local env_path = vim.fn.getcwd() .. "/.envs/" .. name;
        local file, err = io.open(env_path, "w")
        if not file then
            -- If there was an error opening the file, handle the error
            print("Error creating the file: " .. err)
        else
            file:close()
            self:enter(env_path)
        end
    end,
    buf_labels_refresh = function(self)
        for _, win_id in ipairs(api.nvim_tabpage_list_wins(2)) do
            local buf_name = u.get_buf_name_by_win_id(win_id)
            local title = "%= %t %=";
            if self.selected and self.selected == buf_name then
                title = "%= selected: %t %=";
            elseif self.alternator and self.alternator == buf_name then
                title = "%= alternative: %t %=";
            end
            api.nvim_win_set_option(win_id, "statusline", title)
        end
    end,
    status = {
        text = "",
        update = function(self)
            if self.paths and #self.paths > 0 then
                self.text = "No env files in workspace's directory"
            elseif not self.paths then
                self.text = "No envs directory in workspace"
            else
                self.text = #self.paths .. " enviornments"
            end
            tabs_controller.redraw_line()
        end
    }
}
