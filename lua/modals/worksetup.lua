local u = require('utils')

local get_sample_modal = function(title, height, yoffset, zindex)
    local buf_id = api.nvim_create_buf(true, true)
    local blueprint = {
        relative = "editor",
        width = 40,
        height = height,
        border = "rounded",
        style = "minimal",
        title = "",
        title_pos = "center",
        zindex = zindex
    }
    return {
        buf_id = buf_id,
        win_id = nil, -- This is volatile are usually really volatile
        blueprint = blueprint,
        get_build = function()
            return vim.tbl_extend("force", blueprint, { col = u.get_centered_col(blueprint.width), row = u.get_centered_row(blueprint.height) + yoffset, title = title })
        end
    }
end


return {
    name = nil,
    path = nil,
    section_win_ids = nil,
    _add_callbacks = function(self, buf_id, enter_message)
        vim.keymap.set({ "i", "n" }, "<enter>", function() self:create() end, { buffer = buf_id })
        vim.keymap.set({ "i", "n" }, "<c-c>", function() self:hide() end, { buffer = buf_id })
        vim.keymap.set({ "i", "n" }, "<tab>", function() self:cycle() end, { buffer = buf_id })
        if enter_message then
            vim.api.nvim_create_autocmd({ "WinEnter" }, {
                callback = function()
                    local statuscontrol = require("tabs.controller")
                    statuscontrol.urgent_status = enter_message
                    statuscontrol.redraw_line()
                end,
                buffer = buf_id
            })
        end
        vim.api.nvim_create_autocmd({ "WinEnter" }, {
            callback = function()
                if not vim.tbl_contains(self.section_win_ids, api.nvim_get_current_win()) then
                    pcall(function() self:hide()end)
                    return true
                end
            end,
        })
    end,
    show = function(self, init_name, init_path)
        if not self.name then
            self.name = get_sample_modal("< New workspace name >", 1, 0, 51)
            self.path = get_sample_modal("< At path >", 1, 2, 52)
        end
        self.name.win_id = api.nvim_open_win(self.name.buf_id, true, self.name:get_build())
        self.path.win_id = api.nvim_open_win(self.path.buf_id, false, self.path:get_build())
        if init_name then
                vim.api.nvim_buf_set_lines(self.name.buf_id, 0, 1, true, { init_name })
        end
        if init_path then
                vim.api.nvim_buf_set_lines(self.path.buf_id, 0, 1, true, { init_path})
        else
                vim.api.nvim_buf_set_lines(self.path.buf_id, 0, 1, true, { vim.fn.getcwd() })
        end
        self.section_win_ids = { self.name.win_id, self.path.win_id }
        self:_add_callbacks(self.name.buf_id, "")
        self:_add_callbacks(self.path.buf_id, "")
    end,
    cycle = function(self)
        local currently_on = api.nvim_get_current_win()
        for i = 1, #self.section_win_ids do
            if currently_on == self.section_win_ids[i] and i < #self.section_win_ids then
                vim.api.nvim_set_current_win(self.section_win_ids[i + 1])
                return true
            elseif currently_on == self.section_win_ids[i] then
                vim.api.nvim_set_current_win(self.section_win_ids[1])
                return true
            end
        end
    end,
    hide = function(self)
        api.nvim_win_hide(self.name.win_id)
        api.nvim_win_hide(self.path.win_id)
    end,
    create = function(self)
        local name = vim.api.nvim_buf_get_lines(self.name.buf_id, 0, 1, true)[1]
        local path = vim.api.nvim_buf_get_lines(self.path.buf_id, 0, 1, true)[1]
        if vim.fn.isdirectory(path) then
                vim.fn.system("mkdir -p '" .. path .. "'")
        end
        require("workspaces").add(path, name)
        require("workspaces").open(name)
    end,
    cancel = function(self)
        api.nvim_del_current_line();
        self:hide();
    end
}
