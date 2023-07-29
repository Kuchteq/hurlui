local u = require('utils')
local tabs_controller = require("tabs.controller")
local get_env_editor = require('panels.get_env_editor')


return {
    inited = false,
    paths = nil, -- nil means env has not yet been initialized,
    -- false directory is non existant and {} that there are no files in directory
    env_editors = {},
    alternator = nil,
    alternate = function(self)
        -- If we don't have an alternator, we grab the first thing that isn't selected
        if self.paths and #self.paths > 1 then
            if not self.alternator then
                self.alternator = u.first_not_present(self.paths, self.selected);
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
        tabs_controller:redraw_line()
    end,
    set_default_selected = function(self)
        self.selected = self.paths and u.contains_substring_in_table(self.paths, DEFAULT_ENVSPACE_NAME) or nil
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
        local runner_tab = require("tabs.runner")
        vim.api.nvim_set_current_tabpage(2)
        self:rescan()
        if not self.inited and self.paths and #self.paths > 0 then
            for i = 1, #self.paths do
                if i == 1 then
                    vim.cmd.edit(self.paths[1])
                else
                    vim.cmd.vsplit(self.paths[i])
                end
                local new_window = get_env_editor():init();
                vim.bo.filetype = "sh"
                table.insert(self.env_editors, new_window);
                api.nvim_win_set_hl_ns(new_window.win.id, ENV_EDITOR_NS);
            end
            self.inited = true
        elseif not self.paths or #self.paths <= 0 then
            require("modals.envsetup").show()
            self.status:update()
        end
        self:buf_labels_refresh()
    end,
    add = function(self, name)
        local env_path = "./.envs/" .. name;
        local file, err = io.open(env_path, "w")
        if not file then
            -- If there was an error opening the file, handle the error
            print("Error creating the file: " .. err)
        else
            file:close()
            if self.inited then
                vim.api.nvim_set_current_tabpage(2)
                vim.cmd.vsplit(env_path)
                local new_window = get_env_editor():init();
                table.insert(self.env_editors, new_window);
                api.nvim_win_set_hl_ns(new_window.win.id, ENV_EDITOR_NS);
                self:buf_labels_refresh()
            else
                self:enter()
            end
        end
    end,
    buf_labels_refresh = function(self)
        P(self.env_editors)
        for i = 1, #self.env_editors do
            local editor = self.env_editors[i]
            local title = "%= %t %=";
            if u.get_file_name(editor.win:get_file_path()) == u.get_file_name(self.selected) then
                title = "%= selected: %t %=";
            elseif self.alternator and u.get_file_name(editor.win:get_file_path()) == u.get_file_name(self.alternator) then
                title = "%= alternative: %t %=";
            end
            api.nvim_win_set_option(editor.win.id, "statusline", title)
        end
    end,
    status = {
        text = "",
        update = function(self)
            P(self.paths)
            P(self.paths)
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
