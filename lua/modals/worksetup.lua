local u = require('utils')

local get_sample_modal = function(title, height, y_offset, on_enter_message)
    local blueprint = {
        relative = "editor",
        width = 40,
        height = height,
        border = "rounded",
        style = "minimal",
        title = "",
        title_pos = "center"
    }
    local buf_id = api.nvim_create_buf(true, true)

    if on_enter_message then
        vim.api.nvim_create_autocmd({ "WinEnter" }, {
            callback = function()
                local statuscontrol = require("tabs.controller")
                statuscontrol.urgent_status = on_enter_message
                statuscontrol.redraw_line()
            end,
            buffer = buf_id
        })
    end
    return {
        buf_id = buf_id,
        win_id = nil, -- This is volatile are usually really volatile
        blueprint = blueprint,
        on_enter_message = on_enter_message,
        get_build = function()
            return vim.tbl_extend("force", blueprint, { col = u.get_centered_col(blueprint.width), row = u.get_centered_row(blueprint.height) + y_offset, title = title })
        end
    }
end

return {
    name = get_sample_modal("< New workspace name >", 1, 0, ""),
    path = get_sample_modal("< At path >", 1, 3, "Enter path or open file picker with <c-n>"),
    show = function(self)
        if not self.name.win_id then
            vim.keymap.set({ "i", "n" }, "<enter>", function() self:create() end, { buffer = self.name.buf_id })
            vim.keymap.set({ "i", "n" }, "<enter>", function() self:create() end, { buffer = self.path.buf_id })
            vim.keymap.set("i", "tab", function() self:create() end, { buffer = self.name.buf_id })
            vim.keymap.set({ "n", "i" }, "<c-c>", function() self:cancel() end, {buffer= self.name.buf_id})
            vim.keymap.set({ "n", "i" }, "<Tab>", function() self:cycle() end, { buffer = self.name.buf_id })
            vim.keymap.set({ "n", "i" }, "<Tab>", function() self:cycle() end, { buffer = self.path.buf_id })
            --self.boot.buf_id = api.nvim_create_buf(false, true)
        end
        --        api.nvim_buf_set_lines(self.buf_id, 0, -1, true, { "You can add content here." })
        self.name.win_id = api.nvim_open_win(self.name.buf_id, true, self.name:get_build())
        self.path.win_id = api.nvim_open_win(self.path.buf_id, false, self.path:get_build())
        vim.api.nvim_buf_set_lines(self.path.buf_id, 0, 1, true, { vim.fn.getcwd() })
        self.section_win_ids = { self.name.win_id, self.path.win_id }
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
        require("workspaces").add(name, path)
        require("workspaces").open(name)
    end,
    cancel = function(self)
        api.nvim_del_current_line();
        self:hide();
    end
}
